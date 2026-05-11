import crypto from 'crypto';

// VNPAY Configuration
export const vnpayConfig = {
  vnp_TmnCode: process.env.VNPAY_TMN_CODE || 'G2P4PHXX',
  vnp_HashSecret: process.env.VNPAY_HASH_SECRET || '7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK',
  vnp_Url: process.env.VNPAY_URL || 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
  vnp_ReturnUrl: process.env.VNPAY_RETURN_URL || 'http://localhost:3000/payments/vnpay-return',
  vnp_IpnUrl: process.env.VNPAY_IPN_URL || 'http://localhost:3000/payments/vnpay-ipn',
  vnp_ApiUrl: process.env.VNPAY_API_URL || 'https://sandbox.vnpayment.vn/merchant_weblogic/api/transaction',
};

/**
 * Helper function to generate checksum for VNPAY request
 */
export function generateChecksum(data: Record<string, any>, hashSecret: string): string {
  const sortedKeys = Object.keys(data).sort();
  const dataString = sortedKeys
    .map((key) => `${key}=${encodeURIComponent(String(data[key]))}`)
    .join('&');

  return crypto
    .createHmac('sha512', hashSecret)
    .update(dataString)
    .digest('hex');
}

/**
 * Helper function to verify VNPAY IPN callback
 */
export function verifyVNPAYChecksum(
  data: Record<string, any>,
  checksum: string,
  hashSecret: string
): boolean {
  const generatedChecksum = generateChecksum(data, hashSecret);
  return generatedChecksum === checksum;
}

/**
 * Generate unique order ID
 */
export function generateOrderId(): string {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000000)
    .toString()
    .padStart(6, '0');
  return `${timestamp}${random}`;
}

/**
 * Format amount for VNPAY (multiply by 100)
 */
export function formatAmount(amount: number): number {
  return Math.round(amount * 100);
}

/**
 * Parse amount from VNPAY response (divide by 100)
 */
export function parseAmount(vnpAmount: number): number {
  return vnpAmount / 100;
}

/**
 * Get current date in YYYYMMDD format for VNPAY
 */
export function getCurrentDate(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}${month}${day}`;
}

/**
 * Get current time in HHmmss format for VNPAY
 */
export function getCurrentTime(): string {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');
  return `${hours}${minutes}${seconds}`;
}
