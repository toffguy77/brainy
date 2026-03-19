/* eslint-disable @typescript-eslint/no-explicit-any */

// ── Firestore mocks ──
const mockSet = jest.fn().mockResolvedValue(undefined);
const mockUpdate = jest.fn().mockResolvedValue(undefined);
const mockGet = jest.fn();
const mockDocRef = jest.fn(() => ({ set: mockSet, update: mockUpdate, get: mockGet }));
const mockWhere = jest.fn().mockReturnThis();
const mockQueryGet = jest.fn().mockResolvedValue({ docs: [], size: 0 });
const mockCollection = jest.fn(() => ({
  doc: mockDocRef,
  where: mockWhere,
  get: mockQueryGet,
}));

const mockNowMillis = jest.fn(() => Date.now());

jest.mock("firebase-admin", () => ({
  apps: [{}],
  initializeApp: jest.fn(),
  firestore: Object.assign(jest.fn(() => ({ collection: mockCollection })), {
    FieldValue: { serverTimestamp: jest.fn(() => "SERVER_TIMESTAMP") },
    Timestamp: {
      fromDate: jest.fn((d: Date) => ({ toMillis: () => d.getTime(), toDate: () => d })),
      now: jest.fn(() => ({ toMillis: mockNowMillis })),
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

import { checkSubscription } from "../checkSubscription";

const handler = checkSubscription as any;

describe("checkSubscription", () => {
  beforeEach(() => jest.clearAllMocks());

  it("throws invalid-argument when deviceId is missing", async () => {
    await expect(handler({ data: {} })).rejects.toMatchObject({ code: "invalid-argument" });
  });

  it("throws invalid-argument when deviceId is not a string", async () => {
    await expect(handler({ data: { deviceId: 123 } })).rejects.toMatchObject({ code: "invalid-argument" });
  });

  it("returns isPremium: false when no subscription exists", async () => {
    mockGet.mockResolvedValueOnce({ exists: false });

    const result = await handler({ data: { deviceId: "dev-1" } });

    expect(result).toEqual({ isPremium: false, plan: null, expiresAt: null });
  });

  it("returns isPremium: true for active non-expired subscription", async () => {
    const futureDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // +30 days
    mockGet.mockResolvedValueOnce({
      exists: true,
      data: () => ({
        status: "active",
        plan: "monthly",
        expiresAt: { toMillis: () => futureDate.getTime(), toDate: () => futureDate },
      }),
    });

    const result = await handler({ data: { deviceId: "dev-1" } });

    expect(result.isPremium).toBe(true);
    expect(result.plan).toBe("monthly");
    expect(result.expiresAt).toBe(futureDate.toISOString());
  });

  it("returns isPremium: false for active but expired subscription", async () => {
    const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000); // -1 day
    mockGet.mockResolvedValueOnce({
      exists: true,
      data: () => ({
        status: "active",
        plan: "monthly",
        expiresAt: { toMillis: () => pastDate.getTime(), toDate: () => pastDate },
      }),
    });

    const result = await handler({ data: { deviceId: "dev-1" } });

    expect(result.isPremium).toBe(false);
    expect(result.plan).toBeNull();
    expect(result.expiresAt).toBeNull();
  });

  it("returns isPremium: false for canceled subscription", async () => {
    const futureDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    mockGet.mockResolvedValueOnce({
      exists: true,
      data: () => ({
        status: "canceled",
        plan: "monthly",
        expiresAt: { toMillis: () => futureDate.getTime(), toDate: () => futureDate },
      }),
    });

    const result = await handler({ data: { deviceId: "dev-1" } });

    expect(result.isPremium).toBe(false);
    expect(result.plan).toBeNull();
    expect(result.expiresAt).toBeNull();
  });
});
