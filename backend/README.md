# Dennis Mom Backend API

Node.js + Express + MongoDB backend for the Dennis Mom inventory app.

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Set up Environment Variables
Copy `.env.example` to `.env`:
```bash
copy .env.example .env
```

Edit `.env` and configure:
- `MONGODB_URI`: Your MongoDB connection string
- `JWT_SECRET`: A secure random string for JWT signing
- `PORT`: Server port (default: 3000)

### 3. Set up MongoDB

**Option A: Local MongoDB**
1. Install MongoDB from https://www.mongodb.com/try/download/community
2. Start MongoDB service
3. Use default URI: `mongodb://localhost:27017/dennis_mom_db`

**Option B: MongoDB Atlas (Cloud)**
1. Go to https://www.mongodb.com/cloud/atlas/register
2. Create a free cluster
3. Get connection string and update `MONGODB_URI` in `.env`

### 4. Start the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

Server will run on `http://localhost:3000`

## API Endpoints

### Authentication

**POST /api/auth/register**
- Register a new user
- Body: `{ "email": "user@example.com", "password": "password123", "role": "customer|vendor" }`
- Returns: JWT token and user info

**POST /api/auth/login**
- Login existing user
- Body: `{ "email": "user@example.com", "password": "password123" }`
- Returns: JWT token and user info

**GET /api/auth/me**
- Get current user info
- Headers: `Authorization: Bearer <token>`
- Returns: User info

### Items

**GET /api/items**
- Get all items (public, no auth required)
- Returns: Array of items

**GET /api/items/:id**
- Get single item by ID (public)
- Returns: Item object

**POST /api/items**
- Create new item (vendor only)
- Headers: `Authorization: Bearer <token>`
- Body: `{ "name": "Item Name", "description": "Description", "price": 29.99, "imageUrl": "https://...", "stock": 10 }`
- Returns: Created item

**PUT /api/items/:id**
- Update item (vendor only)
- Headers: `Authorization: Bearer <token>`
- Body: Updated fields
- Returns: Updated item

**DELETE /api/items/:id**
- Delete item (vendor only)
- Headers: `Authorization: Bearer <token>`
- Returns: Deleted item

## Testing the API

Use a tool like Postman or curl to test endpoints:

```bash
# Health check
curl http://localhost:3000/health

# Register a vendor
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"vendor@test.com\",\"password\":\"password123\",\"role\":\"vendor\"}"

# Get all items
curl http://localhost:3000/api/items
```
