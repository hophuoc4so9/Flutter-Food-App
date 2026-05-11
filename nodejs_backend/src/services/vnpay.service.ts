import {
  vnpayConfig,
  generateChecksum,
  formatAmount,
  generateOrderId,
  getCurrentDate,
  getCurrentTime,
} from '../config/vnpay.config.js';

export interface CreatePaymentRequest {
  userId: string;
  amount: number;
  description: string;
  ipAddr?: string;
}

export interface PaymentResponse {
  orderId: string;
  paymentUrl: string;
  amount: number;
}

export class VNPAYService {
  /**
   * Create payment request to VNPAY
   */
  static createPayment(request: CreatePaymentRequest): PaymentResponse {
    const orderId = generateOrderId();
    const amount = formatAmount(request.amount);
    const currentDate = getCurrentDate();
    const currentTime = getCurrentTime();
    const ipAddr = request.ipAddr || '127.0.0.1';

    const vnpParams: Record<string, any> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: vnpayConfig.vnp_TmnCode,
      vnp_Merchant: '',
      vnp_OrderInfo: request.description,
      vnp_OrderType: 'order',
      vnp_Amount: amount,
      vnp_Locale: 'vn',
      vnp_CurrCode: 'VND',
      vnp_TxnRef: orderId,
      vnp_ReturnUrl: vnpayConfig.vnp_ReturnUrl,
      vnp_IpAddr: ipAddr,
      vnp_CreateDate: `${currentDate}${currentTime}`,
    };

    // Generate secure hash
    const secureHash = generateChecksum(vnpParams, vnpayConfig.vnp_HashSecret);
    vnpParams.vnp_SecureHash = secureHash;

    // Build payment URL
    const paymentUrl = this.buildPaymentUrl(vnpParams);

    return {
      orderId,
      paymentUrl,
      amount: request.amount,
    };
  }

  /**
   * Build complete payment URL with parameters
   */
  private static buildPaymentUrl(params: Record<string, any>): string {
    const queryString = Object.keys(params)
      .sort()
      .map((key) => `${key}=${encodeURIComponent(String(params[key]))}`)
      .join('&');

    return `${vnpayConfig.vnp_Url}?${queryString}`;
  }

  /**
   * Query payment status from VNPAY (optional - for checking status)
   */
  static getPaymentStatus(orderId: string, transactionDate: string): Record<string, any> {
    const queryParams: Record<string, any> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'querydr',
      vnp_TmnCode: vnpayConfig.vnp_TmnCode,
      vnp_TxnRef: orderId,
      vnp_TransactionDate: transactionDate,
      vnp_CreateDate: `${getCurrentDate()}${getCurrentTime()}`,
    };

    const secureHash = generateChecksum(queryParams, vnpayConfig.vnp_HashSecret);
    queryParams.vnp_SecureHash = secureHash;

    return queryParams;
  }

  /**
   * Refund payment (if applicable)
   */
  static refundPayment(
    orderId: string,
    amount: number,
    transactionDate: string
  ): Record<string, any> {
    const refundParams: Record<string, any> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'refund',
      vnp_TmnCode: vnpayConfig.vnp_TmnCode,
      vnp_TxnRef: orderId,
      vnp_Amount: formatAmount(amount),
      vnp_TransactionDate: transactionDate,
      vnp_CreateDate: `${getCurrentDate()}${getCurrentTime()}`,
      vnp_CreateBy: 'api',
    };

    const secureHash = generateChecksum(refundParams, vnpayConfig.vnp_HashSecret);
    refundParams.vnp_SecureHash = secureHash;

    return refundParams;
  }
}
