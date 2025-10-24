const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// ----------------------------
// Middleware
// ----------------------------
app.use(cors()); // Allow cross-origin requests from Flutter app
app.use(express.json()); // Parse JSON request bodies

// ----------------------------
// Database Connection
// ----------------------------
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/dennis_mom_db';

mongoose
  .connect(MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

// ----------------------------
// Routes
// ----------------------------
app.use('/api/auth', require('./routes/auth'));
app.use('/api/items', require('./routes/items'));
app.use('/api/orders', require('./routes/orders'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// ----------------------------
// Start Server
// ----------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
