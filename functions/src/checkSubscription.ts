import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const checkSubscription = onCall(async (request) => {
  const { deviceId } = request.data as { deviceId?: string };

  if (!deviceId || typeof deviceId !== "string") {
    throw new HttpsError("invalid-argument", "deviceId is required");
  }

  const doc = await db.collection("subscriptions").doc(deviceId).get();

  if (!doc.exists) {
    return {
      isPremium: false,
      plan: null,
      expiresAt: null,
    };
  }

  const data = doc.data()!;
  const expiresAt = data.expiresAt as admin.firestore.Timestamp;
  const now = admin.firestore.Timestamp.now();
  const isPremium = data.status === "active" && expiresAt.toMillis() > now.toMillis();

  return {
    isPremium,
    plan: isPremium ? data.plan : null,
    expiresAt: isPremium ? expiresAt.toDate().toISOString() : null,
  };
});
