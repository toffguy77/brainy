/* eslint-disable @typescript-eslint/no-explicit-any */

// ── Firestore mocks ──
const mockSet = jest.fn().mockResolvedValue(undefined);
const mockUpdate = jest.fn().mockResolvedValue(undefined);
const mockGet = jest.fn().mockResolvedValue({ exists: true, data: () => ({}), id: "test-id" });
const mockDocRef = jest.fn(() => ({ set: mockSet, update: mockUpdate, get: mockGet }));
const mockWhere = jest.fn().mockReturnThis();
const mockQueryGet = jest.fn().mockResolvedValue({ docs: [], size: 0 });
const mockCollection = jest.fn(() => ({
  doc: mockDocRef,
  where: mockWhere,
  get: mockQueryGet,
}));

jest.mock("firebase-admin", () => ({
  apps: [{}],
  initializeApp: jest.fn(),
  firestore: Object.assign(jest.fn(() => ({ collection: mockCollection })), {
    FieldValue: { serverTimestamp: jest.fn(() => "SERVER_TIMESTAMP") },
    Timestamp: {
      fromDate: jest.fn((d: Date) => ({ toMillis: () => d.getTime(), toDate: () => d })),
      now: jest.fn(() => ({ toMillis: () => Date.now() })),
    },
  }),
}));

jest.mock("axios", () => ({
  __esModule: true,
  default: { post: jest.fn(), isAxiosError: jest.fn() },
}));

class HttpsError extends Error {
  code: string;
  constructor(code: string, message: string) {
    super(message);
    this.code = code;
  }
}

jest.mock("firebase-functions/v2/https", () => ({
  onCall: jest.fn((handler: any) => handler),
  onRequest: jest.fn((handler: any) => handler),
  HttpsError,
}));

jest.mock("firebase-functions/v2/scheduler", () => ({
  onSchedule: jest.fn((_schedule: string, handler: any) => handler),
}));

import { yookassaWebhook } from "../yookassaWebhook";

const handler = yookassaWebhook as any;

function makeReqRes(method: string, body: any) {
  const req = { method, body } as any;
  const res = {
    status: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
  } as any;
  return { req, res };
}

describe("yookassaWebhook", () => {
  beforeEach(() => jest.clearAllMocks());

  it("returns 405 for non-POST requests", async () => {
    const { req, res } = makeReqRes("GET", {});
    await handler(req, res);
    expect(res.status).toHaveBeenCalledWith(405);
    expect(res.send).toHaveBeenCalledWith("Method Not Allowed");
  });

  it("returns 400 for invalid payload (missing object.id)", async () => {
    const { req, res } = makeReqRes("POST", { event: "payment.succeeded", object: {} });
    await handler(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it("returns 400 when object is missing entirely", async () => {
    const { req, res } = makeReqRes("POST", { event: "payment.succeeded" });
    await handler(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it("handles payment.succeeded and creates subscription (monthly)", async () => {
    const { req, res } = makeReqRes("POST", {
      event: "payment.succeeded",
      object: {
        id: "pay-1",
        status: "succeeded",
        metadata: { deviceId: "dev-1", plan: "monthly" },
        payment_method: { id: "pm-1", saved: true },
      },
    });

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);

    // Payment updated
    expect(mockCollection).toHaveBeenCalledWith("payments");
    expect(mockDocRef).toHaveBeenCalledWith("pay-1");
    expect(mockUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        status: "succeeded",
        paymentMethodId: "pm-1",
      })
    );

    // Subscription created
    expect(mockCollection).toHaveBeenCalledWith("subscriptions");
    expect(mockDocRef).toHaveBeenCalledWith("dev-1");
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({
        deviceId: "dev-1",
        plan: "monthly",
        status: "active",
        paymentMethodId: "pm-1",
      })
    );
  });

  it("handles payment.succeeded (yearly) with correct expiry", async () => {
    const { req, res } = makeReqRes("POST", {
      event: "payment.succeeded",
      object: {
        id: "pay-2",
        status: "succeeded",
        metadata: { deviceId: "dev-2", plan: "yearly" },
        payment_method: { id: "pm-2" },
      },
    });

    const before = new Date();
    await handler(req, res);

    const admin = require("firebase-admin");
    const fromDateCalls = admin.firestore.Timestamp.fromDate.mock.calls;
    const expiryDate: Date = fromDateCalls[fromDateCalls.length - 1][0];
    expect(expiryDate.getFullYear()).toBe(before.getFullYear() + 1);
  });

  it("handles payment.succeeded without metadata (no subscription created)", async () => {
    const { req, res } = makeReqRes("POST", {
      event: "payment.succeeded",
      object: {
        id: "pay-3",
        status: "succeeded",
      },
    });

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(mockUpdate).toHaveBeenCalledTimes(1); // payment updated
    expect(mockSet).not.toHaveBeenCalled(); // no subscription
  });

  it("handles payment.canceled", async () => {
    const { req, res } = makeReqRes("POST", {
      event: "payment.canceled",
      object: { id: "pay-4", status: "canceled" },
    });

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(mockUpdate).toHaveBeenCalledWith(
      expect.objectContaining({ status: "canceled" })
    );
    expect(mockSet).not.toHaveBeenCalled();
  });

  it("returns 200 for unknown event types", async () => {
    const { req, res } = makeReqRes("POST", {
      event: "payment.refunded",
      object: { id: "pay-5", status: "refunded" },
    });

    await handler(req, res);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it("returns 200 even on processing errors", async () => {
    mockUpdate.mockRejectedValueOnce(new Error("Firestore error"));

    const { req, res } = makeReqRes("POST", {
      event: "payment.succeeded",
      object: { id: "pay-6", status: "succeeded" },
    });

    await handler(req, res);
    expect(res.status).toHaveBeenCalledWith(200);
  });
});
