# Swagger API Documentation Setup

## Overview

Swagger/OpenAPI documentation has been implemented for all APIs in the Food App backend. This provides an interactive UI to explore, understand, and test all available endpoints.

## Access Swagger UI

Once the server is running, access the Swagger documentation at:

```
http://localhost:3000/api-docs
```

### Swagger Features
- ✅ Interactive API exploration
- ✅ Try it out functionality to test endpoints directly
- ✅ Request/response schemas
- ✅ Authentication token support
- ✅ Parameter validation
- ✅ Error response documentation

## API Categories

### 1. Authentication Endpoints
**Base Path:** `/users`

#### Create User (Register)
- **Endpoint:** `POST /users/createUser`
- **Description:** Register a new user account
- **Request:** email, password
- **Response:** User object with ID and email
- **Authentication:** Not required

#### Login
- **Endpoint:** `POST /users/login`
- **Description:** Login to get JWT token
- **Request:** email, password
- **Response:** JWT token
- **Authentication:** Not required

### 2. Password Reset Endpoints
**Base Path:** `/users`

#### Forgot Password
- **Endpoint:** `POST /users/forgot-password`
- **Description:** Request password reset - sends OTP to email
- **Request:** email
- **Response:** Confirmation message
- **Authentication:** Not required
- **OTP Expiry:** 10 minutes

#### Reset Password
- **Endpoint:** `POST /users/reset-password`
- **Description:** Reset password using OTP
- **Request:** email, otp (6-digit), newPassword
- **Response:** Success confirmation
- **Authentication:** Not required

### 3. Email Verification Endpoints
**Base Path:** `/users`

#### Send OTP
- **Endpoint:** `POST /users/send-otp`
- **Description:** Send OTP to user's email for verification
- **Request:** email
- **Response:** Confirmation message
- **Authentication:** Not required
- **OTP Expiry:** 10 minutes

#### Verify OTP
- **Endpoint:** `POST /users/verify-otp`
- **Description:** Verify OTP code to mark email as verified
- **Request:** email, otp (6-digit)
- **Response:** Verification status
- **Authentication:** Not required

#### Resend OTP
- **Endpoint:** `POST /users/resend-otp`
- **Description:** Resend OTP if user didn't receive
- **Request:** email
- **Response:** Confirmation message
- **Authentication:** Not required

### 4. Todo Management Endpoints
**Base Path:** `/todos`
**Authentication:** Required (Bearer token)

#### Create Todo
- **Endpoint:** `POST /todos/createToDo`
- **Description:** Create a new todo item
- **Request:** title, description (optional)
- **Response:** Created todo object
- **Authentication:** Required

#### Get User Todos
- **Endpoint:** `GET /todos/getUserTodoList`
- **Description:** Retrieve all todos for authenticated user
- **Request:** None (uses auth token)
- **Response:** Array of todo objects
- **Authentication:** Required

#### Update Todo
- **Endpoint:** `POST /todos/updateTodo`
- **Description:** Update a todo item
- **Request:** id, title (optional), description (optional), isCompleted (optional)
- **Response:** Updated todo object
- **Authentication:** Required

#### Delete Todo
- **Endpoint:** `POST /todos/deleteTodo`
- **Description:** Delete a todo item
- **Request:** id
- **Response:** Success confirmation
- **Authentication:** Required

## Testing with Swagger UI

### Step 1: Simple Endpoint (No Auth)

1. Navigate to **Authentication** section
2. Click on `POST /users/login`
3. Click "Try it out"
4. Enter test credentials:
   ```json
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```
5. Click "Execute"
6. View the response

### Step 2: Authenticated Endpoints

1. First, get a token from login endpoint
2. Copy the token from response
3. Click the "Authorize" button (lock icon at top right)
4. In the authorization dialog:
   - **Authorization type:** Bearer
   - **Token:** Paste your JWT token
5. Click "Authorize"
6. Now you can test protected endpoints like `/todos/getUserTodoList`

### Step 3: Test Password Reset Flow

1. **Step 1:** Call `POST /users/forgot-password`
   ```json
   {
     "email": "user@example.com"
   }
   ```

2. **Step 2:** Check email for OTP code

3. **Step 3:** Call `POST /users/reset-password`
   ```json
   {
     "email": "user@example.com",
     "otp": "123456",
     "newPassword": "newpassword123"
   }
   ```

## Using JWT Token in Swagger

### Authorize Button
- Click the lock icon (Authorize) at top right of Swagger UI
- Enter token in format: `Bearer YOUR_TOKEN_HERE`
- Or just enter the token (Bearer is automatically added)

### Token Persistence
- Tokens persist in Swagger UI during your session
- Tokens are stored in browser's session storage
- Clear browser data to reset authorization

## API Response Format

### Success Response
```json
{
  "status": true,
  "success": {
    "_id": "...",
    "email": "user@example.com",
    ...
  }
}
```

### Error Response
```json
{
  "status": false,
  "message": "Error description"
}
```

## Security

### Authentication
- All Todo endpoints require JWT token
- Token is included in Authorization header
- Token format: `Authorization: Bearer <token>`

### Password Security
- Passwords are bcrypt hashed (10 rounds)
- OTP is 6-digit random number
- OTP expires after 10 minutes
- Reset token is one-time use only

## Swagger Configuration

### Files
- **Swagger Config:** `src/config/swagger.config.ts`
  - OpenAPI 3.0 specification
  - Server configuration
  - Schema definitions
  - Security schemes

- **Route Documentation:** 
  - `src/routes/user.route.ts` - User endpoints
  - `src/routes/todo.route.ts` - Todo endpoints

### Swagger Annotations
- JSDoc comments with `@swagger` tags
- Detailed endpoint descriptions
- Request/response schemas
- Example values

## Customization

### Add New Endpoint Documentation

Add Swagger comments above your route handler:

```typescript
/**
 * @swagger
 * /api/endpoint:
 *   post:
 *     tags:
 *       - Category
 *     summary: Short description
 *     description: Detailed description
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               field:
 *                 type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.post("/endpoint", controller.method);
```

### Update Server URL

Edit `src/config/swagger.config.ts`:
```typescript
servers: [
    {
        url: 'http://localhost:3000',
        description: 'Development server'
    },
    {
        url: 'https://api.production.com',
        description: 'Production server'
    }
]
```

## Production Deployment

### Before Going Live

1. **Update Server URLs** - Add production domain
2. **Security** - Ensure HTTPS is enabled
3. **API Key** - Consider adding API key authentication
4. **Rate Limiting** - Implement rate limiting on endpoints
5. **CORS** - Configure allowed origins in production

### Disable Swagger in Production (Optional)

Add to `app.ts`:
```typescript
if (process.env.NODE_ENV !== 'production') {
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}
```

## Troubleshooting

### Swagger UI Not Loading
- Check if swagger package is installed: `npm list swagger-ui-express`
- Verify swagger config file exists
- Check browser console for errors

### Endpoints Not Appearing
- Ensure JSDoc comments have correct syntax
- Check file paths in swagger.config.ts `apis` array
- Rebuild with `npm run build`

### Authentication Not Working
- Ensure token is in correct format with "Bearer " prefix
- Check token hasn't expired
- Verify JWT_SECRET matches in `.env`

## Packages Installed

```json
{
  "swagger-ui-express": "^4.x.x",
  "swagger-jsdoc": "^6.x.x"
}
```

## Resources

- [Swagger/OpenAPI Documentation](https://swagger.io/specification/)
- [Swagger UI GitHub](https://github.com/swagger-api/swagger-ui)
- [Swagger JSDoc GitHub](https://github.com/Surnet/swagger-jsdoc)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)

---

## Quick Start Checklist

- [x] Install swagger packages
- [x] Create swagger configuration
- [x] Add Swagger UI to app
- [x] Document all user endpoints
- [x] Document all todo endpoints
- [x] Test endpoints in Swagger UI
- [ ] Add rate limiting (optional)
- [ ] Deploy to production

---

## Example cURL Commands

### Create User
```bash
curl -X POST http://localhost:3000/users/createUser \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

### Get Todo List (with token)
```bash
curl -X GET http://localhost:3000/todos/getUserTodoList \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Create Todo
```bash
curl -X POST http://localhost:3000/todos/createToDo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Buy groceries",
    "description": "Milk, bread, eggs"
  }'
```

---

Visit **http://localhost:3000/api-docs** to start exploring the API!
