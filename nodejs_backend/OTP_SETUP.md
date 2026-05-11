# OTP (One-Time Password) Implementation Guide

## Overview

OTP (One-Time Password) authentication has been implemented for email verification. Users receive a 6-digit code via email that they can use to verify their email address.

## Features

1. **Send OTP** - Generates and sends a 6-digit OTP to user's email
2. **Verify OTP** - Validates OTP and marks email as verified
3. **Resend OTP** - Sends a new OTP (useful if user didn't receive the first one)
4. **Email Verification Status** - Tracks whether user's email has been verified

## API Endpoints

### 1. Send OTP
**POST** `/api/users/send-otp`

Generate and send OTP to user's email address.

**Request Body:**
```json
{
    "email": "user@example.com"
}
```

**Success Response (200):**
```json
{
    "status": true,
    "message": "OTP sent successfully to your email"
}
```

**Error Response (400):**
```json
{
    "status": false,
    "message": "Email not found in our system"
}
```

**Flow:**
1. Validate email is provided
2. Check if user exists in database
3. Generate random 6-digit OTP
4. Save OTP to database with 10-minute expiration
5. Send OTP via email with HTML template
6. Return success message

---

### 2. Verify OTP
**POST** `/api/users/verify-otp`

Verify the OTP code sent to user's email.

**Request Body:**
```json
{
    "email": "user@example.com",
    "otp": "123456"
}
```

**Success Response (200):**
```json
{
    "status": true,
    "message": "Email verified successfully",
    "success": {
        "email": "user@example.com",
        "isEmailVerified": true
    }
}
```

**Error Response (400):**
```json
{
    "status": false,
    "message": "Invalid or expired OTP"
}
```

**Flow:**
1. Validate email and OTP are provided
2. Validate OTP format (6 digits)
3. Query database for matching OTP and email
4. Check if OTP hasn't expired
5. Mark email as verified
6. Clear OTP from database
7. Return success with verification status

---

### 3. Resend OTP
**POST** `/api/users/resend-otp`

Resend OTP if user didn't receive the first one.

**Request Body:**
```json
{
    "email": "user@example.com"
}
```

**Success Response (200):**
```json
{
    "status": true,
    "message": "New OTP sent successfully to your email"
}
```

**Error Response (400):**
```json
{
    "status": false,
    "message": "Email not found in our system"
}
```

**Flow:**
1. Validate email is provided
2. Check if user exists
3. Generate new 6-digit OTP
4. Update OTP and expiration in database
5. Send new OTP via email
6. Return success message

---

## OTP Configuration

### OTP Details
- **Format:** 6-digit number
- **Expiration:** 10 minutes
- **Generation:** Cryptographically secure random number
- **Storage:** Plain text in database (intended for short-term use)
- **One-time Use:** OTP is deleted after successful verification

### Email Template

The OTP email includes:
- Professional HTML formatting
- Large, easy-to-read OTP display
- Clear expiration time
- Plain text fallback
- Support for all email clients

Example email shows:
```
OTP: 123456
This code will expire in 10 minutes.
```

---

## Database Schema

The User model includes OTP fields:

```typescript
otpCode: {
    type: String,
    default: null,
}

otpExpire: {
    type: Date,
    default: null,
}

isEmailVerified: {
    type: Boolean,
    default: false,
}
```

---

## SMTP Configuration

The system uses the following SMTP variables from `.env`:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=hophuoc4so9@gmail.com
SMTP_PASS=gfsrgcrrwcfoxrss
MAIL_FROM="FOOD APP from <hophuoc4so9@gmail.com>"
```

---

## Testing OTP Flow with Postman

### Step 1: Send OTP
```
Method: POST
URL: http://localhost:3000/api/users/send-otp
Body: {
    "email": "user@example.com"
}
```

**Expected Response:**
```
Status: 200
{
    "status": true,
    "message": "OTP sent successfully to your email"
}
```

### Step 2: Wait for Email
Check inbox for email with OTP code (or check email service logs).

### Step 3: Verify OTP
```
Method: POST
URL: http://localhost:3000/api/users/verify-otp
Body: {
    "email": "user@example.com",
    "otp": "123456"  // Replace with actual OTP from email
}
```

**Expected Response:**
```
Status: 200
{
    "status": true,
    "message": "Email verified successfully",
    "success": {
        "email": "user@example.com",
        "isEmailVerified": true
    }
}
```

### Step 4: Resend OTP (Optional)
If user didn't receive OTP:
```
Method: POST
URL: http://localhost:3000/api/users/resend-otp
Body: {
    "email": "user@example.com"
}
```

---

## Frontend Integration

### Using Dart/Flutter

```dart
// Step 1: Send OTP
Future<void> sendOTP(String email) async {
    final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
    );
    
    if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
            print('OTP sent successfully');
            // Navigate to OTP verification page
        }
    }
}

// Step 2: Verify OTP
Future<void> verifyOTP(String email, String otp) async {
    final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
    );
    
    if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
            print('Email verified successfully');
            // Proceed to next step
        }
    }
}

// Step 3: Resend OTP
Future<void> resendOTP(String email) async {
    final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
    );
    
    if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
            print('New OTP sent');
        }
    }
}
```

---

## Error Handling

### Common Errors

1. **Email Not Found**
   - Message: "Email not found in our system"
   - Cause: User hasn't registered yet
   - Solution: Create user account first

2. **Invalid OTP**
   - Message: "Invalid or expired OTP"
   - Cause: Wrong OTP or expired (10 minutes)
   - Solution: Resend OTP and try again

3. **OTP Format Invalid**
   - Message: "OTP must be 6 digits"
   - Cause: OTP is not exactly 6 digits
   - Solution: Enter exactly 6-digit OTP

4. **Email Service Error**
   - Message: "Error sending OTP"
   - Cause: SMTP configuration issue
   - Solution: Check SMTP_HOST, SMTP_USER, SMTP_PASS in .env

---

## Security Considerations

✅ **Implemented:**
- OTP is 6-digit random number (1 million possibilities)
- 10-minute expiration
- One-time use (deleted after verification)
- No OTP stored after successful verification
- Email verification status tracked

**Recommendations:**
- Monitor failed OTP attempts (rate limiting)
- Log OTP verification attempts
- Consider adding CAPTCHA for repeated failures
- Use HTTPS in production

---

## Troubleshooting

### OTP Email Not Received

1. **Check spam/junk folder** - OTP emails might be flagged as spam
2. **Verify SMTP configuration** - Check .env file
3. **Check logs** - Look for email sending errors
4. **Resend OTP** - Use resend endpoint to request new code

### OTP Expired

- OTP expires after 10 minutes
- User should resend OTP using `/resend-otp` endpoint
- New OTP is valid for another 10 minutes

### Database Issues

- Ensure MongoDB is running
- Check MONGO_URI connection string
- Verify database has users collection

---

## Next Steps

1. **Frontend Setup** - Create OTP verification UI in Flutter app
2. **User Flow** - Integrate OTP into registration/login process
3. **Rate Limiting** - Add rate limiting to prevent abuse
4. **SMS Alternative** - Consider adding SMS OTP option
5. **Backup Codes** - Generate backup codes for account recovery

---

## Files Modified

- `src/models/user.model.ts` - Added OTP fields
- `src/services/user.service.ts` - Added OTP generation/verification
- `src/services/email.service.ts` - Added OTP email template
- `src/controller/user.controller.ts` - Added OTP endpoints
- `src/routes/user.route.ts` - Added OTP routes
- `.env` - Already has SMTP configuration
