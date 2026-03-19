import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import axios from "axios";
import { randomUUID } from "crypto";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const PRICES: Record<string, number> = {
  monthly: 299,
  yearly: 1990,
};

export const createPayment = onCall(async (request) => {
  const { paymentToken, deviceId, plan } = request.data as {
    paymentToken?: string;
    deviceId?: string;
    plan?: string;
  };

  if (!paymentToken || typeof paymentToken !== "string") {
    throw new HttpsError("invalid-argument", "paymentToken is required");
  }
  if (!deviceId || typeof deviceId !== "string") {
    throw new HttpsError("invalid-argument", "deviceId is required");
  }
  if (plan !== "monthly" && plan !== "yearly") {
    throw new HttpsError("invalid-argument", "plan must be 'monthly' or 'yearly'");
  }

  const shopId = process.env.YOOKASSA_SHOP_ID;
  const secretKey = process.env.YOOKASSA_SECRET_KEY;

  if (!shopId || !secretKey) {
    throw new HttpsError("internal", "YooKassa credentials not configured");
  }

  const amount = PRICES[plan];
  const idempotencyKey = randomUUID();

  try {
    const response = await axios.post(
      "https://api.yookassa.ru/v3/payments",
      {
        amount: {
          value: amount.toFixed(2),
          currency: "RUB",
        },
        payment_token: paymentToken,
        capture: true,
        save_payment_method: true,
        description: `Brainy Pro ${plan}`,
        metadata: {
          deviceId,
          plan,
        },
      },
      {
        auth: {
          username: shopId,
          password: secretKey,
        },
        headers: {
          "Idempotence-Key": idempotencyKey,
          "Content-Type": "application/json",
        },
      }
    );

    const payment = response.data;

    // Store payment in Firestore
    await db.collection("payments").doc(payment.id).set({
      paymentId: payment.id,
      deviceId,
      plan,
      amount,
      status: payment.status,
      paymentMethodId: payment.payment_method?.id || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (payment.status === "pending" && payment.confirmation?.confirmation_url) {
      return {
        status: "pending",
        confirmationUrl: payment.confirmation.confirmation_url,
      };
    }

    if (payment.status === "succeeded") {
      // Update subscription immediately
      const now = new Date();
      const expiresAt = new Date(now);
      if (plan === "monthly") {
        expiresAt.setMonth(expiresAt.getMonth() + 1);
      } else {
        expiresAt.setFullYear(expiresAt.getFullYear() + 1);
      }

      await db.collection("subscriptions").doc(deviceId).set({
        deviceId,
        plan,
        status: "active",
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
        paymentMethodId: payment.payment_method?.id || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { status: "succeeded" };
    }

    if (payment.status === "canceled") {
      return { status: "canceled" };
    }

    return { status: payment.status };
  } catch (error: unknown) {
    if (axios.isAxiosError(error)) {
      console.error("YooKassa API error:", error.response?.data);
      throw new HttpsError("internal", "Payment creation failed");
    }
    throw error;
  }
});
