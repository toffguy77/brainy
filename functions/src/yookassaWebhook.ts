import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface YookassaPaymentObject {
  id: string;
  status: string;
  metadata?: {
    deviceId?: string;
    plan?: string;
  };
  payment_method?: {
    id?: string;
    saved?: boolean;
  };
}

interface YookassaWebhookEvent {
  type: string;
  event: string;
  object: YookassaPaymentObject;
}

export const yookassaWebhook = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const body = req.body as YookassaWebhookEvent;
  const eventType = body.event;
  const payment = body.object;

  if (!payment || !payment.id) {
    console.error("Invalid webhook payload:", body);
    res.status(400).send("Invalid payload");
    return;
  }

  try {
    if (eventType === "payment.succeeded") {
      // Update payment status
      await db.collection("payments").doc(payment.id).update({
        status: "succeeded",
        paymentMethodId: payment.payment_method?.id || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Create/update subscription
      const deviceId = payment.metadata?.deviceId;
      const plan = payment.metadata?.plan;

      if (deviceId && plan) {
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
      }
    } else if (eventType === "payment.canceled") {
      await db.collection("payments").doc(payment.id).update({
        status: "canceled",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    res.status(200).send("OK");
  } catch (error) {
    console.error("Webhook processing error:", error);
    res.status(200).send("OK");
  }
});
