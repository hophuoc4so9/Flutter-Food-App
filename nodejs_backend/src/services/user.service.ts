import UserModel from '../models/user.model.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

class UserService {
    static async registerUser(email: string, password: string): Promise<any> {
        try {
            const createUser = new UserModel({
                email,
                password
            });
            const savedUser = await createUser.save();
            return savedUser;
        } catch (error) {
            throw error;
        }
    }

    static async getUserByEmail(email: string): Promise<any> {
        try {
            const user = await UserModel.findOne({ email });
            return user;
        } catch (error) {
            throw error;
        }
    }

    static async checkUser(email: string): Promise<any> {
        try {
            return await UserModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    static async generateAccessToken(tokenData: any, JWTSecret: string, expiresIn: string): Promise<string> {
        return jwt.sign(tokenData, JWTSecret, { expiresIn: expiresIn as any });
    }

    static generateOTP(): string {
        // Generate a 6-digit OTP
        return Math.floor(100000 + Math.random() * 900000).toString();
    }

    static async forgotPassword(email: string): Promise<any> {
        try {
            const user = await UserModel.findOne({ email });
            if (!user) {
                throw new Error('User not found');
            }

            // Generate OTP for password reset
            const otp = this.generateOTP();

            // Set OTP and expiration time (10 minutes)
            user.otpCode = otp;
            user.otpExpire = new Date(Date.now() + 10 * 60 * 1000);
            user.isPasswordResetVerified = false;

            await user.save();

            return {
                user,
                otp // Return OTP to send via email
            };
        } catch (error) {
            throw error;
        }
    }

    static async resetPassword(email: string, otp: string, newPassword: string): Promise<any> {
        try {
            // Verify OTP
            const user = await UserModel.findOne({
                email,
                otpCode: otp,
                otpExpire: { $gt: new Date() }
            });

            if (!user) {
                throw new Error('Invalid or expired OTP');
            }

            // Update password
            user.password = newPassword;
            user.otpCode = null;
            user.otpExpire = null;
            user.isPasswordResetVerified = true;

            await user.save();

            return user;
        } catch (error) {
            throw error;
        }
    }

    static async sendOTP(email: string): Promise<any> {
        try {
            const user = await UserModel.findOne({ email });
            if (!user) {
                throw new Error('User not found');
            }

            // Generate OTP
            const otp = this.generateOTP();

            // Set OTP and expiration time (10 minutes)
            user.otpCode = otp;
            user.otpExpire = new Date(Date.now() + 10 * 60 * 1000);

            await user.save();

            return {
                user,
                otp // Return OTP to send via email
            };
        } catch (error) {
            throw error;
        }
    }

    static async verifyOTP(email: string, otp: string): Promise<any> {
        try {
            const user = await UserModel.findOne({
                email,
                otpCode: otp,
                otpExpire: { $gt: new Date() }
            });

            if (!user) {
                throw new Error('Invalid or expired OTP');
            }

            // Mark email as verified and clear OTP
            user.isEmailVerified = true;
            user.otpCode = null;
            user.otpExpire = null;

            await user.save();

            return user;
        } catch (error) {
            throw error;
        }
    }

    static async getUserById(id: string): Promise<any> {
        try {
            const user = await UserModel.findById(id);
            return user;
        } catch (error) {
            throw error;
        }
    }
}

export default UserService;
