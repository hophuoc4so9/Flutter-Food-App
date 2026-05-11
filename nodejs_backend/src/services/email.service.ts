import transporter from '../config/email.config.js';

class EmailService {
    static async sendPasswordResetEmail(email: string, resetToken: string, resetLink: string): Promise<boolean> {
        try {
            const mailOptions = {
                from: process.env.MAIL_FROM || process.env.SMTP_USER,
                to: email,
                subject: 'Password Reset Request',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                        <h2 style="color: #333;">Password Reset Request</h2>
                        <p style="color: #666; line-height: 1.6;">
                            You have requested a password reset. Please click the button below to reset your password.
                        </p>
                        <p style="margin: 20px 0;">
                            <a href="${resetLink}?token=${resetToken}" 
                               style="display: inline-block; background-color: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                                Reset Password
                            </a>
                        </p>
                        <p style="color: #999; font-size: 12px;">
                            This link will expire in 1 hour. If you didn't request a password reset, please ignore this email.
                        </p>
                        <p style="color: #999; font-size: 12px;">
                            Or copy and paste this link in your browser: <br/>
                            ${resetLink}?token=${resetToken}
                        </p>
                    </div>
                `,
                text: `
                    Password Reset Request
                    
                    You have requested a password reset. Visit the link below to reset your password:
                    ${resetLink}?token=${resetToken}
                    
                    This link will expire in 1 hour.
                    If you didn't request a password reset, please ignore this email.
                `
            };

            const result = await transporter.sendMail(mailOptions);
            console.log('Password reset email sent:', result.messageId);
            return true;
        } catch (error) {
            console.error('Error sending password reset email:', error);
            throw error;
        }
    }

    static async sendOTPEmail(email: string, otp: string): Promise<boolean> {
        try {
            const mailOptions = {
                from: process.env.MAIL_FROM || process.env.SMTP_USER,
                to: email,
                subject: 'Your OTP Code - Food App',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                        <h2 style="color: #333;">Email Verification</h2>
                        <p style="color: #666; line-height: 1.6;">
                            Your One-Time Password (OTP) is:
                        </p>
                        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0; border-radius: 5px;">
                            <p style="font-size: 40px; font-weight: bold; color: #007bff; margin: 0; letter-spacing: 8px;">
                                ${otp}
                            </p>
                        </div>
                        <p style="color: #666; line-height: 1.6;">
                            Please enter this code in the app to verify your account. Do not share this code with anyone.
                        </p>
                        <p style="color: #999; font-size: 12px;">
                            This code will expire in 10 minutes.
                        </p>
                        <p style="color: #999; font-size: 12px;">
                            If you didn't request this code, please ignore this email or contact support.
                        </p>
                    </div>
                `,
                text: `
                    Email Verification
                    
                    Your One-Time Password (OTP) is: ${otp}
                    
                    Please enter this code in the app to verify your account.
                    Do not share this code with anyone.
                    
                    This code will expire in 10 minutes.
                    If you didn't request this code, please ignore this email.
                `
            };

            const result = await transporter.sendMail(mailOptions);
            console.log('OTP email sent:', result.messageId);
            return true;
        } catch (error) {
            console.error('Error sending OTP email:', error);
            throw error;
        }
    }

    static async sendVerificationEmail(email: string, verificationCode: string): Promise<boolean> {
        try {
            const mailOptions = {
                from: process.env.MAIL_FROM || process.env.SMTP_USER,
                to: email,
                subject: 'Email Verification',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                        <h2 style="color: #333;">Email Verification</h2>
                        <p style="color: #666; line-height: 1.6;">
                            Thank you for registering. Please verify your email with the code below:
                        </p>
                        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0; border-radius: 5px;">
                            <p style="font-size: 32px; font-weight: bold; color: #007bff; margin: 0; letter-spacing: 5px;">
                                ${verificationCode}
                            </p>
                        </div>
                        <p style="color: #999; font-size: 12px;">
                            This code will expire in 15 minutes.
                        </p>
                    </div>
                `,
                text: `
                    Email Verification
                    
                    Verification Code: ${verificationCode}
                    
                    This code will expire in 15 minutes.
                `
            };

            const result = await transporter.sendMail(mailOptions);
            console.log('Verification email sent:', result.messageId);
            return true;
        } catch (error) {
            console.error('Error sending verification email:', error);
            throw error;
        }
    }

    static async sendWelcomeEmail(email: string): Promise<boolean> {
        try {
            const mailOptions = {
                from: process.env.MAIL_FROM || process.env.SMTP_USER,
                to: email,
                subject: 'Welcome to Food App',
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                        <h2 style="color: #333;">Welcome to Food App!</h2>
                        <p style="color: #666; line-height: 1.6;">
                            Thank you for registering. Your account has been successfully created.
                        </p>
                        <p style="color: #666; line-height: 1.6;">
                            You can now log in and start using our application.
                        </p>
                    </div>
                `
            };

            const result = await transporter.sendMail(mailOptions);
            console.log('Welcome email sent:', result.messageId);
            return true;
        } catch (error) {
            console.error('Error sending welcome email:', error);
            throw error;
        }
    }

    static async sendNotificationEmail(email: string, subject: string, message: string): Promise<boolean> {
        try {
            const mailOptions = {
                from: process.env.MAIL_FROM || process.env.SMTP_USER,
                to: email,
                subject: subject,
                html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                        <h2 style="color: #333;">Notification</h2>
                        <p style="color: #666; line-height: 1.6;">
                            ${message}
                        </p>
                    </div>
                `,
                text: message
            };

            const result = await transporter.sendMail(mailOptions);
            console.log('Notification email sent:', result.messageId);
            return true;
        } catch (error) {
            console.error('Error sending notification email:', error);
            throw error;
        }
    }
}

export default EmailService;
