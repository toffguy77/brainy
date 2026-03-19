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

// ── axios mock ──
const mockAxiosPost = jest.fn();
const mockIsAxiosError = jest.fn();
jest.mock("axios", () => ({
  __esModule: true,
  default: {
    post: mockAxiosPost,
    isAxiosError: mockIsAxiosError,
  },
}));

// ── firebase-functions mocks ──
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

// ── Import the handler (after mocks) ──
import { createPayment } from "../createPayment";

const handler = createPayment as any;

describe("createPayment", () => {
  const validData = { paymentToken: "tok_test", deviceId: "device-1", plan: "monthly" };

  beforeEach(() => {
    jest.clearAllMocks();
    process.env.YOOKASSA_SHOP_ID = "shop-123";
    process.env.YOOKASSA_SECRET_KEY = "secret-456";
  });

  afterEach(() => {
    delete process.env.YOOKASSA_SHOP_ID;
    delete process.env.YOOKASSA_SECRET_KEY;
  });

  // ── Input validation ──

  it("throws invalid-argument when paymentToken is missing", async () => {
    await expect(handler({ data: { deviceId: "d", plan: "monthly" } }))
      .rejects.toThrow(HttpsError);
    await expect(handler({ data: { deviceId: "d", plan: "monthly" } }))
      .rejects.toMatchObject({ code: "invalid-argument" });
  });

  it("throws invalid-argument when deviceId is missing", async () => {
    await expect(handler({ data: { paymentToken: "t", plan: "monthly" } }))
      .rejects.toMatchObject({ code: "invalid-argument" });
  });

  it("throws invalid-argument when plan is invalid", async () => {
    await expect(handler({ data: { paymentToken: "t", deviceId: "d", plan: "weekly" } }))
      .rejects.toMatchObject({ code: "invalid-argument" });
  });

  // ── Missing credentials ──

  it("throws internal when YOOKASSA_SHOP_ID is missing", async () => {
    delete process.env.YOOKASSA_SHOP_ID;
    await expect(handler({ data: validData }))
      .rejects.toMatchObject({ code: "internal" });
  });

  it("throws internal when YOOKASSA_SECRET_KEY is missing", async () => {
    delete process.env.YOOKASSA_SECRET_KEY;
    await expect(handler({ data: validData }))
      .rejects.toMatchObject({ code: "internal" });
  });

  // ── Successful payment (monthly) ──

  it("handles succeeded payment (monthly), stores payment & subscription", async () => {
    mockAxiosPost.mockResolvedValueOnce({
      data: {
        id: "pay-1",
        status: "succeeded",
        payment_method: { id: "pm-1" },
      },
    });

    const result = await handler({ data: validData });

    expect(result).toEqual({ status: "succeeded" });

    // Payment stored
    expect(mockCollection).toHaveBeenCalledWith("payments");
    expect(mockDocRef).toHaveBeenCalledWith("pay-1");
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({
        paymentId: "pay-1",
        deviceId: "device-1",
        plan: "monthly",
        amount: 299,
        status: "succeeded",
        paymentMethodId: "pm-1",
      })
    );

    // Subscription stored
    expect(mockCollection).toHaveBeenCalledWith("subscriptions");
    expect(mockDocRef).toHaveBeenCalledWith("device-1");
    const subCall = mockSet.mock.calls[1][0];
    expect(subCall.plan).toBe("monthly");
    expect(subCall.status).toBe("active");
    expect(subCall.deviceId).toBe("device-1");
  });

  // ── Successful payment (yearly) ──

  it("handles succeeded payment (yearly), expiresAt is +1 year", async () => {
    mockAxiosPost.mockResolvedValueOnce({
      data: {
        id: "pay-2",
        status: "succeeded",
        payment_method: { id: "pm-2" },
      },
    });

    const before = new Date();
    const result = await handler({ data: { ...validData, plan: "yearly" } });
    expect(result).toEqual({ status: "succeeded" });

    // Check Timestamp.fromDate was called with a date ~1 year from now
    const admin = require("firebase-admin");
    const fromDateCalls = admin.firestore.Timestamp.fromDate.mock.calls;
    const expiryDate: Date = fromDateCalls[fromDateCalls.length - 1][0];
    const expectedYear = before.getFullYear() + 1;
    expect(expiryDate.getFullYear()).toBe(expectedYear);
  });

  // ── Pending payment (3DS) ──

  it("returns pending with confirmationUrl for 3DS flow", async () => {
    mockAxiosPost.mockResolvedValueOnce({
      data: {
        id: "pay-3",
        status: "pending",
        confirmation: { confirmation_url: "https://3ds.example.com" },
        payment_method: { id: "pm-3" },
      },
    });

    const result = await handler({ data: validData });

    expect(result).toEqual({
      status: "pending",
      confirmationUrl: "https://3ds.example.com",
    });

    // Payment stored
    expect(mockSet).toHaveBeenCalledTimes(1);
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({ status: "pending" })
    );
  });

  // ── Canceled payment ──

  it("returns canceled status", async () => {
    mockAxiosPost.mockResolvedValueOnce({
      data: {
        id: "pay-4",
        status: "canceled",
      },
    });

    const result = await handler({ data: validData });
    expect(result).toEqual({ status: "canceled" });

    // Payment stored, no subscription
    expect(mockSet).toHaveBeenCalledTimes(1);
    expect(mockSet).toHaveBeenCalledWith(
      expect.objectContaining({ status: "canceled" })
    );
  });

  // ── YooKassa API error ──

  it("throws internal error when YooKassa API fails", async () => {
    const apiError = new Error("Network Error");
    mockAxiosPost.mockRejectedValueOnce(apiError);
    mockIsAxiosError.mockReturnValueOnce(true);

    await expect(handler({ data: validData }))
      .rejects.toMatchObject({ code: "internal" });
  });

  // ── Correct API call verification ──

  it("calls YooKassa API with correct parameters", async () => {
    mockAxiosPost.mockResolvedValueOnce({
      data: { id: "pay-5", status: "succeeded", payment_method: { id: "pm-5" } },
    });

    await handler({ data: validData });

    expect(mockAxiosPost).toHaveBeenCalledWith(
      "https://api.yookassa.ru/v3/payments",
      expect.objectContaining({
        amount: { value: "299.00", currency: "RUB" },
        payment_token: "tok_test",
        capture: true,
        save_payment_method: true,
        description: "Brainy Pro monthly",
        metadata: { deviceId: "device-1", plan: "monthly" },
      }),
      expect.objectContaining({
        auth: { username: "shop-123", password: "secret-456" },
        headers: expect.objectContaining({
          "Content-Type": "application/json",
        }),
      })
    );
  });
});
