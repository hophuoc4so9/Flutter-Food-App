import UserService from '../services/user.service.js';
import EmailService from '../services/email.service.js';

export class UserController {
    static async createUser(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, password } = req.body;
            const duplicate = await UserService.checkUser(email);
            if (duplicate) {
                return res.json({ status: false, message: "Email already exists" });
            }
            const newUser = await UserService.registerUser(email, password);
            res.json({ status: true, success: newUser });
        } catch (err) {
            next(err);
        }
    }

    static async loginUser(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, password } = req.body;
            const user = await UserService.getUserByEmail(email);
            if (!user) {
                return res.json({ status: false, message: "User not found" });
            }
            const isMatch = await user.comparePassword(password);
            if (!isMatch) {
                return res.json({ status: false, message: "User or password is incorrect" });
            }
            const tokenData = { _id: user._id, email: user.email };
            const token = await UserService.generateAccessToken(tokenData, process.env.JWT_SECRET || 'secret', '72h');
            res.status(200).json({ status: true, success: { token } });
        } catch (err) {
            next(err);
        }
    }

    static async forgotPassword(req: any, res: any, next: any): Promise<any> {
        try {
            const { email } = req.body;

            if (!email) {
                return res.status(400).json({ status: false, message: "Email is required" });
            }

            // Check if user exists
            const userExists = await UserService.checkUser(email);
            if (!userExists) {
                return res.json({ status: false, message: "Email not found in our system" });
            }

            // Generate OTP for password reset
            const { otp } = await UserService.forgotPassword(email);

            // Send OTP via email
            await EmailService.sendOTPEmail(email, otp);

            res.status(200).json({
                status: true,
                message: "OTP sent successfully to your email for password reset"
            });
        } catch (err) {
            console.error('Forgot password error:', err);
            res.status(500).json({ status: false, message: err instanceof Error ? err.message : "Error processing request" });
        }
    }

    static async resetPassword(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, otp, newPassword } = req.body;

            if (!email || !otp || !newPassword) {
                return res.status(400).json({ status: false, message: "Email, OTP and new password are required" });
            }

            if (otp.length !== 6 || !/^\d+$/.test(otp)) {
                return res.status(400).json({ status: false, message: "OTP must be 6 digits" });
            }

            if (newPassword.length < 6) {
                return res.status(400).json({ status: false, message: "Password must be at least 6 characters long" });
            }

            // Reset password with OTP verification
            const user = await UserService.resetPassword(email, otp, newPassword);

            res.status(200).json({
                status: true,
                message: "Password reset successfully",
                success: {
                    email: user.email
                }
            });
        } catch (err) {
            console.error('Reset password error:', err);
            res.status(400).json({ status: false, message: err instanceof Error ? err.message : "Error resetting password" });
        }
    }

    static async sendOTP(req: any, res: any, next: any): Promise<any> {
        try {
            const { email } = req.body;

            if (!email) {
                return res.status(400).json({ status: false, message: "Email is required" });
            }

            // Check if user exists
            const userExists = await UserService.checkUser(email);
            if (!userExists) {
                return res.json({ status: false, message: "Email not found in our system" });
            }

            // Generate and send OTP
            const { otp } = await UserService.sendOTP(email);

            // Send OTP via email
            await EmailService.sendOTPEmail(email, otp);

            res.status(200).json({
                status: true,
                message: "OTP sent successfully to your email"
            });
        } catch (err) {
            console.error('Send OTP error:', err);
            res.status(500).json({ status: false, message: err instanceof Error ? err.message : "Error sending OTP" });
        }
    }

    static async verifyOTP(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, otp } = req.body;

            if (!email || !otp) {
                return res.status(400).json({ status: false, message: "Email and OTP are required" });
            }

            if (otp.length !== 6 || !/^\d+$/.test(otp)) {
                return res.status(400).json({ status: false, message: "OTP must be 6 digits" });
            }

            // Verify OTP
            const user = await UserService.verifyOTP(email, otp);

            res.status(200).json({
                status: true,
                message: "Email verified successfully",
                success: {
                    email: user.email,
                    isEmailVerified: user.isEmailVerified
                }
            });
        } catch (err) {
            console.error('Verify OTP error:', err);
            res.status(400).json({ status: false, message: err instanceof Error ? err.message : "Error verifying OTP" });
        }
    }

    static async resendOTP(req: any, res: any, next: any): Promise<any> {
        try {
            const { email } = req.body;

            if (!email) {
                return res.status(400).json({ status: false, message: "Email is required" });
            }

            // Check if user exists
            const userExists = await UserService.checkUser(email);
            if (!userExists) {
                return res.json({ status: false, message: "Email not found in our system" });
            }

            // Generate and send new OTP
            const { otp } = await UserService.sendOTP(email);

            // Send OTP via email
            await EmailService.sendOTPEmail(email, otp);

            res.status(200).json({
                status: true,
                message: "New OTP sent successfully to your email"
            });
        } catch (err) {
            console.error('Resend OTP error:', err);
            res.status(500).json({ status: false, message: err instanceof Error ? err.message : "Error resending OTP" });
        }
    }

    static async addOrder(req: any, res: any, next: any): Promise<any> {
        try {
            const { userId, food, total } = req.body;

            if (!userId || !food || total === undefined) {
                return res.status(400).json({ status: false, message: "userId, food, and total are required" });
            }

            const updatedUser = await UserService.addOrder(userId, food, total);
            res.json({ status: true, success: updatedUser });
        } catch (err) {
            console.error('Add order error:', err);
            res.status(400).json({ status: false, message: err instanceof Error ? err.message : "Error adding order" });
        }
    }
}
