import { Router } from 'express';
import { PaymentController } from '../controller/payment.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const PaymentRouter = Router();

/**
 * @swagger
 * tags:
 *   - name: Payments
 *     description: Payment management endpoints using VNPAY
 * 
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */

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
 *                 example: 100000
 *               description:
 *                 type: string
 *                 description: Payment description/order details
 *                 example: "Order #12345"
 *     responses:
 *       200:
 *         description: Payment request created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                 success:
 *                   type: object
 *                   properties:
 *                     orderId:
 *                       type: string
 *                     paymentUrl:
 *                       type: string
 *                     amount:
 *                       type: number
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized
 */
PaymentRouter.post('/create-payment', authenticateToken, PaymentController.createPayment);

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
 *         description: Redirects to frontend payment result page
 */
PaymentRouter.get('/vnpay-return', PaymentController.vnpayReturn);

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
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 RspCode:
 *                   type: string
 *                 Message:
 *                   type: string
 */
PaymentRouter.get('/vnpay-ipn', PaymentController.vnpayIPN);

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
 *         example: "1715425400000123456"
 *     responses:
 *       200:
 *         description: Payment status retrieved
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                 success:
 *                   type: object
 *                   properties:
 *                     orderId:
 *                       type: string
 *                     amount:
 *                       type: number
 *                     status:
 *                       type: string
 *                       enum: [PENDING, SUCCESS, FAILED, REFUNDED]
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Payment not found
 */
PaymentRouter.get('/check-status/:orderId', authenticateToken, PaymentController.checkPaymentStatus);

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
 *         description: Filter by payment status
 *       - name: limit
 *         in: query
 *         type: number
 *         default: 10
 *         description: Number of records per page
 *       - name: skip
 *         in: query
 *         type: number
 *         default: 0
 *         description: Number of records to skip
 *     responses:
 *       200:
 *         description: User payments retrieved
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                 success:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: number
 *                     payments:
 *                       type: array
 *       401:
 *         description: Unauthorized
 */
PaymentRouter.get('/user-payments', authenticateToken, PaymentController.getUserPayments);

export default PaymentRouter;
