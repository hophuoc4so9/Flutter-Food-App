# Forgot Password & Email Configuration Guide

## Overview

This guide will help you set up the forgot password functionality and email configuration for your Node.js backend.

## Features Implemented

1. **Forgot Password Endpoint** - Allows users to request a password reset
2. **Reset Password Endpoint** - Allows users to set a new password using reset token
3. **Email Service** - Sends password reset emails with HTML templates
4. **Token Management** - Secure token generation and validation

## Email Configuration

### Option 1: Gmail (Recommended for Development)

1. **Enable 2-Factor Authentication** on your Google Account
2. **Generate App Password**:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer" (or your device type)
   - Google will generate a 16-character password
   - Copy this password

3. **Update your .env file**:
```env
EMAIL_SERVICE=gmail
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=xxxx xxxx xxxx xxxx
EMAIL_FROM=noreply@foodapp.com
FRONTEND_URL=http://localhost:3000
```

### Option 2: Custom SMTP Server

If using SendGrid, Mailgun, or other SMTP providers:

```env
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=apikey
EMAIL_PASSWORD=your_api_key_here
EMAIL_FROM=noreply@foodapp.com
FRONTEND_URL=http://localhost:3000
```

### Option 3: Office 365

```env
EMAIL_HOST=smtp.office365.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your_email@company.com
EMAIL_PASSWORD=your_password_here
EMAIL_FROM=your_email@company.com
FRONTEND_URL=http://localhost:3000
```

## API Endpoints

### 1. Forgot Password
**POST** `/api/users/forgot-password`

**Request Body**:
```json
{
    "email": "user@example.com"
}
```

**Success Response** (200):
```json
{
    "status": true,
    "message": "Password reset email sent successfully"
}
```

**Error Response** (400):
```json
{
    "status": false,
    "message": "Email not found in our system"
}
```

### 2. Reset Password
**POST** `/api/users/reset-password`

**Request Body**:
```json
{
    "resetToken": "token_received_in_email",
    "newPassword": "new_password_here"
}
```

**Success Response** (200):
```json
{
    "status": true,
    "message": "Password reset successfully",
    "success": {
        "email": "user@example.com"
    }
}
```

**Error Response** (400):
```json
{
    "status": false,
    "message": "Invalid or expired reset token"
}
```

## Token Details

- **Token Format**: SHA256 hashed random 32-byte value
- **Token Expiration**: 1 hour
- **Storage**: Hashed token stored in MongoDB, plain token sent via email
- **Security**: Users can only use token once; token is deleted after successful reset

## Environment Variables

Create a `.env` file in the `nodejs_backend` directory with the following:

```env
# Required
MONGODB_URI=mongodb://localhost:27017/food_app
JWT_SECRET=your_secure_jwt_secret_here

# Email Configuration
EMAIL_SERVICE=gmail
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_FROM=noreply@foodapp.com
FRONTEND_URL=http://localhost:3000

# Optional
PORT=5000
NODE_ENV=development
```

## Frontend Integration

### 1. Forgot Password Page
```typescript
// Send email with reset link
const response = await fetch('http://localhost:5000/api/users/forgot-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: userEmail })
});
```

### 2. Reset Password Page
```typescript
// Extract token from URL and submit new password
const queryParams = new URLSearchParams(window.location.search);
const token = queryParams.get('token');

const response = await fetch('http://localhost:5000/api/users/reset-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        resetToken: token,
        newPassword: newPassword
    })
});
```

## Testing with Postman

1. **Step 1: Request Password Reset**
   - Method: POST
   - URL: `http://localhost:5000/api/users/forgot-password`
   - Body: `{"email": "user@example.com"}`

2. **Step 2: Get Reset Token**
   - Check your email for the reset link
   - Extract the token from the link: `http://...?token=xxxxx`

3. **Step 3: Reset Password**
   - Method: POST
   - URL: `http://localhost:5000/api/users/reset-password`
   - Body: `{"resetToken": "token_from_email", "newPassword": "new_password"}`

## Troubleshooting

### Email Not Sending

1. **Gmail Issues**:
   - Verify you generated an App Password (not regular password)
   - Check Gmail account has 2FA enabled
   - Try again after 5 minutes

2. **SMTP Connection Issues**:
   - Verify EMAIL_HOST and EMAIL_PORT are correct
   - Check if EMAIL_SECURE matches your provider (usually false for 587, true for 465)
   - Verify EMAIL_USER and EMAIL_PASSWORD are correct

3. **Check Logs**:
   ```bash
   # Development mode logs will show email transporter status
   npm run dev
   ```

### Invalid or Expired Token

1. Make sure token hasn't expired (1 hour limit)
2. Ensure token is correctly extracted from email link
3. Token can only be used once

## Database Schema

The User model includes:
- `resetPasswordToken` (String, hashed): Stores the hashed reset token
- `resetPasswordExpire` (Date): Stores token expiration time

Existing migration: Already added to user.model.ts

## Security Best Practices

1. ✅ Tokens are SHA256 hashed before storage
2. ✅ Tokens expire after 1 hour
3. ✅ Tokens can only be used once
4. ✅ Passwords are bcrypt hashed before storage
5. ✅ Reset link includes plain token (for user to send back)
6. ✅ Only hashed version stored in database

## Next Steps

1. Copy `.env.example` to `.env` and update with your email credentials
2. Start the backend: `npm run dev`
3. Test the forgot password endpoint with Postman
4. Integrate reset endpoints into your Flutter app
