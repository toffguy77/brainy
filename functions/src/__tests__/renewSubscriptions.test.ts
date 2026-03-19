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

const mockAxiosPost = jest.fn();
const mockIsAxiosError = jest.fn();
jest.mock("axios", () => ({
  __esModule: true,
  default: {
    post: mockAxiosPost,
    isAxiosError: mockIsAxiosError,
  },
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

import { renewSubscriptions } from "../renewSubscriptions";

const handler = renewSubscriptions as any;

function makeMockDoc(data: any) {
  return { data: () => data, id: data.deviceId || "unknown" };
}

describe("renewSubscriptions", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.YOOKASSA_SHOP_ID = "shop-123";
    process.env.YOOKASSA_SECRET_KEY = "secret-456";
  });

  afterEach(() => {
    delete process.env.YOOKASSA_SHOP_ID;
    delete process.env.YOOKASSA_SECRET_KEY;
  });

  it("logs error and returns when credentials are missing", async () => {
    delete process.env.YOOKASSA_SHOP_ID;
    const consoleSpy = jest.spyOn(console, "error").mockImplementation();

    await handler();

    expect(consoleSpy).toHaveBeenCalledWith("YooKassa credentials not configured");
    expect(mockAxiosPost).not.toHaveBeenCalled();
    consoleSpy.mockRestore();
  });

  it("does nothing when no subscriptions need renewal", async () => {
    mockQueryGet.mockResolvedValueOnce({ docs: [], size: 0 });

    await handler();

    expect(mockAxiosPost).not.toHaveBeenCalled();
  });

  it("creates renewal payment with correct amount and payment_method_id", async () => {
    const doc = makeMockDoc({
      deviceId: "dev-1",
      plan: "monthly",
      paymentMethodId: "pm-1",
    });
    mockQueryGet.mockResolvedValueOnce({ docs: [doc], size: 1 });
    mockAxiosPost.mockResolvedValueOnce({
      data: { id: "pay-renew-1", status: "succeeded" },
    });

    await handler();

    expect(mockAxiosPost).toHaveBeenCalledWith(
      "https://api.yookassa.ru/v3/payments",
      expect.objectContaining({
        amount: { value: "299.00", currency: "RUB" },
        payment_method_id: "pm-1",
        capture: true,
        description: "Brainy Pro monthly renewal",
        metadata: { deviceId: "dev-1", plan: "monthly" },
      }),
      expect.objectContaining({
        auth: { username: "shop-123", password: "secret-456" },
      })
    );
  });

  it("skips subscription without paymentMethodId", async () => {
    const doc = makeMockDoc({
      deviceId: "dev-2",
      plan: "monthly",
      paymentMethodId: null,
    });
    mockQueryGet.mockResolvedValueOnce({ docs: [doc], size: 1 });
    const warnSpy = jest.spyOn(console, "warn").mockImplementation();

    await handler();

    expect(mockAxiosPost).not.toHaveBeenCalled();
    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("No payment method")
    );
    warnSpy.mockRestore();
  });

  it("skips subscription with unknown plan", async () => {
    const doc = makeMockDoc({
      deviceId: "dev-3",
      plan: "weekly",
      paymentMethodId: "pm-3",
    });
    mockQueryGet.mockResolvedValueOnce({ docs: [doc], size: 1 });
    const warnSpy = jest.spyOn(console, "warn").mockImplementation();

    await handler();

    expect(mockAxiosPost).not.toHaveBeenCalled();
    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("Unknown plan")
    );
    warnSpy.mockRestore();
  });

  it("continues processing after API error on one subscription", async () => {
    const doc1 = makeMockDoc({ deviceId: "dev-4", plan: "monthly", paymentMethodId: "pm-4" });
    const doc2 = makeMockDoc({ deviceId: "dev-5", plan: "yearly", paymentMethodId: "pm-5" });
    mockQueryGet.mockResolvedValueOnce({ docs: [doc1, doc2], size: 2 });

    const apiError = new Error("API Error");
    mockAxiosPost.mockRejectedValueOnce(apiError);
    mockIsAxiosError.mockReturnValueOnce(true);
    mockAxiosPost.mockResolvedValueOnce({
      data: { id: "pay-renew-5", status: "succeeded" },
    });

    const errorSpy = jest.spyOn(console, "error").mockImplementation();

    await handler();

    // Both subscriptions were attempted
    expect(mockAxiosPost).toHaveBeenCalledTimes(2);
    // Second call should have yearly amount
    expect(mockAxiosPost).toHaveBeenLastCalledWith(
      "https://api.yookassa.ru/v3/payments",
      expect.objectContaining({
        amount: { value: "1990.00", currency: "RUB" },
        payment_method_id: "pm-5",
      }),
      expect.anything()
    );
    errorSpy.mockRestore();
  });

  it("queries Firestore with correct filters (status==active AND expiresAt<=tomorrow)", async () => {
    mockQueryGet.mockResolvedValueOnce({ docs: [], size: 0 });

    await handler();

    expect(mockCollection).toHaveBeenCalledWith("subscriptions");
    expect(mockWhere).toHaveBeenCalledWith("status", "==", "active");
    expect(mockWhere).toHaveBeenCalledWith(
      "expiresAt",
      "<=",
      expect.objectContaining({ toMillis: expect.any(Function) })
    );
  });
});
