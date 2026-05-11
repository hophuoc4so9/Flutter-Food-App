import { Router } from 'express';
import { UserController } from '../controller/user.controller.js';

const UserRouter = Router();

/**
 * @swagger
 * /users/createUser:
 *   post:
 *     tags:
 *       - Authentication
 *     summary: Create a new user account
 *     description: Register a new user with email and password
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 description: Password (minimum 6 characters)
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: User created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 success:
 *                   $ref: '#/components/schemas/User'
 *       400:
 *         description: Email already exists or validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/createUser", UserController.createUser);

/**
 * @swagger
 * /users/login:
 *   post:
 *     tags:
 *       - Authentication
 *     summary: Login user
 *     description: Login with email and password to get JWT token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 success:
 *                   type: object
 *                   properties:
 *                     token:
 *                       type: string
 *                       description: JWT token for authentication
 *       400:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/login", UserController.loginUser);

/**
 * @swagger
 * /users/forgot-password:
 *   post:
 *     tags:
 *       - Password Reset
 *     summary: Request password reset
 *     description: Send OTP to email for password reset
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: OTP sent to email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "OTP sent successfully to your email for password reset"
 *       400:
 *         description: Email not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/forgot-password", UserController.forgotPassword);

/**
 * @swagger
 * /users/reset-password:
 *   post:
 *     tags:
 *       - Password Reset
 *     summary: Reset password with OTP
 *     description: Reset user password using OTP received via email
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *               - newPassword
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               otp:
 *                 type: string
 *                 description: 6-digit OTP from email
 *                 example: "123456"
 *               newPassword:
 *                 type: string
 *                 description: New password (minimum 6 characters)
 *                 example: "newpassword123"
 *     responses:
 *       200:
 *         description: Password reset successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Password reset successfully"
 *                 success:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *       400:
 *         description: Invalid OTP or expired
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/reset-password", UserController.resetPassword);

/**
 * @swagger
 * /users/send-otp:
 *   post:
 *     tags:
 *       - Email Verification
 *     summary: Send OTP for email verification
 *     description: Generate and send 6-digit OTP to user email
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "OTP sent successfully to your email"
 *       400:
 *         description: Email not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/send-otp", UserController.sendOTP);

/**
 * @swagger
 * /users/verify-otp:
 *   post:
 *     tags:
 *       - Email Verification
 *     summary: Verify OTP
 *     description: Verify the OTP code sent to user email
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *               otp:
 *                 type: string
 *                 description: 6-digit OTP
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: Email verified successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Email verified successfully"
 *                 success:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                     isEmailVerified:
 *                       type: boolean
 *       400:
 *         description: Invalid or expired OTP
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/verify-otp", UserController.verifyOTP);

/**
 * @swagger
 * /users/resend-otp:
 *   post:
 *     tags:
 *       - Email Verification
 *     summary: Resend OTP
 *     description: Resend OTP if user didn't receive the first one
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: New OTP sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "New OTP sent successfully to your email"
 *       400:
 *         description: Email not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
UserRouter.post("/resend-otp", UserController.resendOTP);

export default UserRouter;
