import { Request, Response } from 'express';
import { Payment } from '../models/payment.model.js';
import { VNPAYService } from '../services/vnpay.service.js';
import {
  verifyVNPAYChecksum,
  parseAmount,
  generateOrderId,
} from '../config/vnpay.config.js';

export class PaymentController {
  /**
   * @swagger
   * /payments/create-payment:
   *   post:
   *     tags:
   *       - Payments
   *     summary: Create a new payment request
   *     description: Initiate a payment transaction with VNPAY
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - amount
   *               - description
   *             properties:
   *               amount:
   *                 type: number
   *                 description: Payment amount in VND
   *               description:
   *                 type: string
   *                 description: Payment description/order details
   *     responses:
   *       200:
   *         description: Payment request created successfully
   *       400:
   *         description: Invalid request data
   */
  static async createPayment(req: Request, res: Response) {
    try {
      const { amount, description } = req.body;
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({
          status: false,
          message: 'User not authenticated',
        });
      }

      if (!amount || amount <= 0) {
        return res.status(400).json({
          status: false,
          message: 'Invalid amount',
        });
      }

      if (!description) {
        return res.status(400).json({
          status: false,
          message: 'Description is required',
        });
      }

      // Create payment record in database
      const orderId = generateOrderId();
      const payment = new Payment({
        userId,
        orderId,
        amount,
        description,
        status: 'PENDING',
      });

      await payment.save();

      // Generate VNPAY payment request
      const ipAddr =
        (req.headers['x-forwarded-for'] as string) ||
        (req.connection?.remoteAddress as string) ||
        '127.0.0.1';

      const paymentResponse = VNPAYService.createPayment({
        userId,
        amount,
        description,
        ipAddr: ipAddr.split(',')[0],
      });

      // Update payment with VNPAY payment URL
      payment.paymentUrl = paymentResponse.paymentUrl;
      await payment.save();

      return res.status(200).json({
        status: true,
        success: {
          orderId: paymentResponse.orderId,
          paymentUrl: paymentResponse.paymentUrl,
          amount: paymentResponse.amount,
        },
      });
    } catch (error) {
      console.error('Error creating payment:', error);
      return res.status(500).json({
        status: false,
        message: 'Error creating payment',
      });
    }
  }

  /**
   * @swagger
   * /payments/vnpay-return:
   *   get:
   *     tags:
   *       - Payments
   *     summary: VNPAY return URL callback
   *     description: Handle VNPAY return callback after payment attempt
   *     parameters:
   *       - name: vnp_Amount
   *         in: query
   *         type: number
   *       - name: vnp_BankCode
   *         in: query
   *         type: string
   *       - name: vnp_BankTranNo
   *         in: query
   *         type: string
   *       - name: vnp_CardType
   *         in: query
   *         type: string
   *       - name: vnp_OrderInfo
   *         in: query
   *         type: string
   *       - name: vnp_PayDate
   *         in: query
   *         type: string
   *       - name: vnp_ResponseCode
   *         in: query
   *         type: string
   *       - name: vnp_SecureHash
   *         in: query
   *         type: string
   *       - name: vnp_TmnCode
   *         in: query
   *         type: string
   *       - name: vnp_TransactionNo
   *         in: query
   *         type: string
   *       - name: vnp_TxnRef
   *         in: query
   *         type: string
   *     responses:
   *       200:
   *         description: Return URL processed
   */
  static async vnpayReturn(req: Request, res: Response) {
    try {
      const vnpParams = req.query;
      const secureHash = vnpParams.vnp_SecureHash as string;

      // Remove secure hash to verify
      delete vnpParams.vnp_SecureHash;
      delete vnpParams.vnp_SecureHashType;

      // Verify checksum
      const isValid = verifyVNPAYChecksum(
        vnpParams as any,
        secureHash,
        process.env.VNPAY_HASH_SECRET || '7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK'
      );

      if (!isValid) {
        return res.status(400).json({
          status: false,
          message: 'Invalid checksum',
        });
      }

      const orderId = vnpParams.vnp_TxnRef as string;
      const responseCode = vnpParams.vnp_ResponseCode as string;

      // Find payment record
      const payment = await Payment.findOne({ orderId });

      if (!payment) {
        return res.status(404).json({
          status: false,
          message: 'Payment not found',
        });
      }

      // Update payment status based on response code
      if (responseCode === '00') {
        payment.status = 'SUCCESS';
        payment.completedAt = new Date();
        payment.transactionNo = vnpParams.vnp_TransactionNo as string;
        payment.bankCode = vnpParams.vnp_BankCode as string;
        payment.cardType = vnpParams.vnp_CardType as string;
      } else {
        payment.status = 'FAILED';
      }

      await payment.save();

      // Redirect to frontend with status
      const frontendReturnUrl = `${process.env.FLUTTER_APP_URL || 'http://localhost:8080'}/payment-result?orderId=${orderId}&status=${payment.status}`;

      return res.redirect(frontendReturnUrl);
    } catch (error) {
      console.error('Error in VNPAY return:', error);
      return res.status(500).json({
        status: false,
        message: 'Error processing return',
      });
    }
  }

  /**
   * @swagger
   * /payments/vnpay-ipn:
   *   get:
   *     tags:
   *       - Payments
   *     summary: VNPAY IPN callback (server-to-server)
   *     description: Handle IPN callback from VNPAY for payment status updates
   *     parameters:
   *       - name: vnp_Amount
   *         in: query
   *         type: number
   *       - name: vnp_BankCode
   *         in: query
   *         type: string
   *       - name: vnp_BankTranNo
   *         in: query
   *         type: string
   *       - name: vnp_CardType
   *         in: query
   *         type: string
   *       - name: vnp_OrderInfo
   *         in: query
   *         type: string
   *       - name: vnp_PayDate
   *         in: query
   *         type: string
   *       - name: vnp_ResponseCode
   *         in: query
   *         type: string
   *       - name: vnp_SecureHash
   *         in: query
   *         type: string
   *       - name: vnp_TmnCode
   *         in: query
   *         type: string
   *       - name: vnp_TransactionNo
   *         in: query
   *         type: string
   *       - name: vnp_TxnRef
   *         in: query
   *         type: string
   *     responses:
   *       200:
   *         description: IPN processed successfully
   */
  static async vnpayIPN(req: Request, res: Response) {
    try {
      const vnpParams = req.query;
      const secureHash = vnpParams.vnp_SecureHash as string;

      // Remove secure hash to verify
      delete vnpParams.vnp_SecureHash;
      delete vnpParams.vnp_SecureHashType;

      // Verify checksum
      const isValid = verifyVNPAYChecksum(
        vnpParams as any,
        secureHash,
        process.env.VNPAY_HASH_SECRET || '7IG2TM2Y3F8ONYPAPV84W7AIGLSGNIUK'
      );

      if (!isValid) {
        return res.status(200).json({
          RspCode: '97',
          Message: 'Invalid checksum',
        });
      }

      const orderId = vnpParams.vnp_TxnRef as string;
      const responseCode = vnpParams.vnp_ResponseCode as string;
      const amount = parseAmount(parseInt(vnpParams.vnp_Amount as string, 10));

      // Find payment record
      let payment = await Payment.findOne({ orderId });

      if (!payment) {
        return res.status(200).json({
          RspCode: '01',
          Message: 'Payment not found',
        });
      }

      // Update payment status
      if (responseCode === '00') {
        // Only update if status is still PENDING to avoid duplicate processing
        if (payment.status === 'PENDING') {
          payment.status = 'SUCCESS';
          payment.completedAt = new Date();
          payment.transactionNo = vnpParams.vnp_TransactionNo as string;
          payment.vnpayCode = responseCode;
          payment.bankCode = vnpParams.vnp_BankCode as string;
          payment.cardType = vnpParams.vnp_CardType as string;

          await payment.save();
        }

        // Verify amount matches
        if (payment.amount !== amount) {
          return res.status(200).json({
            RspCode: '04',
            Message: 'Invalid amount',
          });
        }

        return res.status(200).json({
          RspCode: '00',
          Message: 'Confirm success',
        });
      } else {
        payment.status = 'FAILED';
        payment.vnpayCode = responseCode;
        await payment.save();

        return res.status(200).json({
          RspCode: '00',
          Message: 'Confirm success',
        });
      }
    } catch (error) {
      console.error('Error in VNPAY IPN:', error);
      return res.status(200).json({
        RspCode: '99',
        Message: 'Unknown error',
      });
    }
  }

  /**
   * @swagger
   * /payments/check-status/{orderId}:
   *   get:
   *     tags:
   *       - Payments
   *     summary: Check payment status
   *     description: Check the status of a payment transaction
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - name: orderId
   *         in: path
   *         required: true
   *         type: string
   *     responses:
   *       200:
   *         description: Payment status retrieved
   */
  static async checkPaymentStatus(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({
          status: false,
          message: 'User not authenticated',
        });
      }

      const payment = await Payment.findOne({ orderId, userId });

      if (!payment) {
        return res.status(404).json({
          status: false,
          message: 'Payment not found',
        });
      }

      return res.status(200).json({
        status: true,
        success: {
          orderId: payment.orderId,
          amount: payment.amount,
          status: payment.status,
          createdAt: payment.createdAt,
          completedAt: payment.completedAt,
          transactionNo: payment.transactionNo,
          bankCode: payment.bankCode,
        },
      });
    } catch (error) {
      console.error('Error checking payment status:', error);
      return res.status(500).json({
        status: false,
        message: 'Error checking payment status',
      });
    }
  }

  /**
   * @swagger
   * /payments/user-payments:
   *   get:
   *     tags:
   *       - Payments
   *     summary: Get user payment history
   *     description: Retrieve all payments for the authenticated user
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - name: status
   *         in: query
   *         type: string
   *         enum: [PENDING, SUCCESS, FAILED, REFUNDED]
   *       - name: limit
   *         in: query
   *         type: number
   *         default: 10
   *       - name: skip
   *         in: query
   *         type: number
   *         default: 0
   *     responses:
   *       200:
   *         description: User payments retrieved
   */
  static async getUserPayments(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      const { status, limit = 10, skip = 0 } = req.query;

      if (!userId) {
        return res.status(401).json({
          status: false,
          message: 'User not authenticated',
        });
      }

      const query: any = { userId };

      if (status) {
        query.status = status;
      }

      const payments = await Payment.find(query)
        .limit(Number(limit))
        .skip(Number(skip))
        .sort({ createdAt: -1 });

      const total = await Payment.countDocuments(query);

      return res.status(200).json({
        status: true,
        success: {
          total,
          payments,
        },
      });
    } catch (error) {
      console.error('Error getting user payments:', error);
      return res.status(500).json({
        status: false,
        message: 'Error retrieving payments',
      });
    }
  }
}
