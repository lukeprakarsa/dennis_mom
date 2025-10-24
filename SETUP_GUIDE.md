# Dennis Mom App - Setup Guide with Authentication

This guide will help you set up and run the Dennis Mom inventory app with Node.js backend authentication.

## Architecture Overview

**Backend (Node.js + Express + MongoDB):**
- User authentication with JWT tokens
- Role-based access control (vendor/customer)
- RESTful API for items and users
- MongoDB for data persistence

**Frontend (Flutter):**
- Login/Registration screens with role selection
- Guest browsing (no login required to browse catalog)
- Vendor dashboard (only for vendor role)
- Cart and checkout functionality

## Setup Steps

### 1. Set Up MongoDB

You have two options:

**Option A: Local MongoDB (Recommended for Development)**
1. Download and install MongoDB Community Server from https://www.mongodb.com/try/download/community
2. Start MongoDB service (it usually starts automatically)
3. MongoDB will run on `mongodb://localhost:27017`

**Option B: MongoDB Atlas (Cloud)**
1. Create free account at https://www.mongodb.com/cloud/atlas/register
2. Create a free cluster (M0)
3. Get your connection string
4. Update `.env` with your Atlas connection string

### 2. Set Up the Backend

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create .env file from example
copy .env.example .env

# Edit .env and set:
# - MONGODB_URI (use local or Atlas connection string)
# - JWT_SECRET (change to a random secure string)
# - PORT (default 3000 is fine)

# Start the backend server
npm run dev
```

The backend should now be running on `http://localhost:3000`

Test it with: `curl http://localhost:3000/health`

### 3. Set Up the Flutter App

```bash
# Navigate back to project root
cd ..

# Install Flutter dependencies
flutter pub get

# Update API base URL if needed
# Open lib/services/api_service.dart
# Update baseUrl if your backend is not on localhost:3000

# Run the Flutter app
flutter run
```

## Testing the App

### Test Backend API (Optional)

You can test the backend independently using curl or Postman:

```bash
# Health check
curl http://localhost:3000/health

# Register a vendor
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"vendor@test.com\",\"password\":\"password123\",\"role\":\"vendor\"}"

# The response will include a token - copy it

# Create an item (use the token from registration)
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d "{\"name\":\"Test Item\",\"description\":\"A test product\",\"price\":29.99,\"imageUrl\":\"https://via.placeholder.com/150\",\"stock\":10}"

# Get all items (no auth needed)
curl http://localhost:3000/api/items
```

### Test Flutter App

1. **Guest Browsing:**
   - Launch the app
   - You'll see the catalog screen
   - Browse items without logging in
   - No vendor button should appear

2. **Register as Customer:**
   - Click the login icon in the app bar
   - Click "Don't have an account? Register"
   - Enter email and password
   - Select "Customer" role
   - Click Register
   - You should be redirected to the catalog
   - You can browse and add to cart
   - No vendor button should appear

3. **Register as Vendor:**
   - Logout (click user icon → Logout)
   - Register a new account with "Vendor" role
   - After login, you should see the vendor FAB (Floating Action Button) at the bottom right
   - Click the vendor button to access the vendor dashboard
   - Add/edit/delete items

4. **Test Vendor Operations:**
   - As a vendor, click the vendor (store) button
   - Go to "Add Items" tab
   - Fill in item details and click "Add Item"
   - Item should appear in the catalog immediately
   - Go to "Edit Items" tab
   - Edit or delete items
   - Changes should reflect in the catalog

## How Authentication Works

1. **User Registration:**
   - Users self-register with email, password, and role (customer/vendor)
   - Backend hashes password and stores user in MongoDB
   - Returns JWT token valid for 7 days

2. **User Login:**
   - User enters email and password
   - Backend verifies credentials
   - Returns JWT token if successful

3. **Token Storage:**
   - Flutter app stores token in SharedPreferences
   - Token persists across app restarts
   - Token is sent with every API request that requires authentication

4. **Role-Based Access:**
   - Only vendors can access `/api/items` POST, PUT, DELETE endpoints
   - Customers and guests can only GET items
   - Frontend shows/hides vendor UI based on user role

5. **Guest Access:**
   - Guests can browse catalog without logging in
   - Guests cannot make purchases or access vendor features

## Troubleshooting

### Backend won't start
- Check MongoDB is running: `mongosh` or check Windows Services
- Check port 3000 is not in use
- Verify `.env` file exists and has correct values

### Flutter app can't connect to backend
- Check backend is running on `http://localhost:3000`
- For Android emulator, change API URL to `http://10.0.2.2:3000` in `lib/services/api_service.dart`
- Check firewall/antivirus isn't blocking connections

### Authentication errors
- Check JWT_SECRET is set in backend `.env`
- Try logging out and logging in again
- Clear app data and restart

### Items not showing up
- Check backend has items in MongoDB
- Check network requests in Flutter debug console
- Verify API endpoint is correct in `api_service.dart`

## Next Steps

- Implement proper checkout flow
- Add order history
- Add email verification
- Add password reset functionality
- Deploy backend to production (Heroku, Railway, etc.)
- Build Flutter app for production
