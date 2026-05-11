import nodemailer from 'nodemailer';

// Create transporter for sending emails
const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true' || process.env.SMTP_SECURE === '1', // true for 465, false for other ports
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
    }
});

// Verify transporter connection
transporter.verify((error: any, success: boolean) => {
    if (error) {
        console.error('Email transporter error:', error);
    } else {
        console.log('Email transporter is ready:', success);
    }
});

export default transporter;
