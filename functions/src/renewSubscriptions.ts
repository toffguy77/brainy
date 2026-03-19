import { onSchedule } from "firebase-functions/v2/scheduler";
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

export const renewSubscriptions = onSchedule("every day 00:00", async () => {
  const shopId = process.env.YOOKASSA_SHOP_ID;
  const secretKey = process.env.YOOKASSA_SECRET_KEY;

  if (!shopId || !secretKey) {
    console.error("YooKassa credentials not configured");
    return;
  }

  const now = new Date();
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);

  const snapshot = await db
    .collection("subscriptions")
    .where("status", "==", "active")
    .where("expiresAt", "<=", admin.firestore.Timestamp.fromDate(tomorrow))
    .get();

  console.log(`Found ${snapshot.size} subscriptions to renew`);

  for (const doc of snapshot.docs) {
    const sub = doc.data();
    const deviceId = sub.deviceId as string;
    const plan = sub.plan as string;
    const paymentMethodId = sub.paymentMethodId as string | null;

    if (!paymentMethodId) {
      console.warn(`No payment method for subscription ${deviceId}, skipping`);
      continue;
    }

    const amount = PRICES[plan];
    if (!amount) {
      console.warn(`Unknown plan '${plan}' for subscription ${deviceId}, skipping`);
      continue;
    }

    try {
      const idempotencyKey = randomUUID();

      const response = await axios.post(
        "https://api.yookassa.ru/v3/payments",
        {
          amount: {
            value: amount.toFixed(2),
            currency: "RUB",
          },
          payment_method_id: paymentMethodId,
          capture: true,
          description: `Brainy Pro ${plan} renewal`,
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

      console.log(
        `Renewal payment created for ${deviceId}: ${response.data.id} (status: ${response.data.status})`
      );
    } catch (error: unknown) {
      if (axios.isAxiosError(error)) {
        console.error(
          `Renewal failed for ${deviceId}:`,
          error.response?.data || error.message
        );
      } else {
        console.error(`Renewal failed for ${deviceId}:`, error);
      }
    }
  }
});
