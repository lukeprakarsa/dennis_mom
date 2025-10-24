const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Item = require('../models/Item');
const { authMiddleware, vendorOnly } = require('../middleware/auth');

// ----------------------------
// GET /api/items
// Get all items (public - no auth required)
// ----------------------------
router.get('/', async (req, res) => {
  try {
    const items = await Item.find().sort({ createdAt: -1 });
    res.json(items);
  } catch (error) {
    console.error('Error fetching items:', error);
    res.status(500).json({ error: 'Server error fetching items' });
  }
});

// ----------------------------
// GET /api/items/:id
// Get single item by ID (public)
// ----------------------------
router.get('/:id', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json(item);
  } catch (error) {
    console.error('Error fetching item:', error);
    res.status(500).json({ error: 'Server error fetching item' });
  }
});

// ----------------------------
// POST /api/items
// Create new item (vendor only)
// ----------------------------
router.post(
  '/',
  [authMiddleware, vendorOnly],
  [
    body('name').notEmpty().trim().withMessage('Name is required'),
    body('description').notEmpty().trim().withMessage('Description is required'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('imageUrl').notEmpty().withMessage('Image URL is required'),
    body('stock').isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
  ],
  async (req, res) => {
    // Validate input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const { name, description, price, imageUrl, stock } = req.body;

      const item = new Item({
        name,
        description,
        price,
        imageUrl,
        stock,
        createdBy: req.user._id,
      });

      await item.save();

      res.status(201).json({
        message: 'Item created successfully',
        item,
      });
    } catch (error) {
      console.error('Error creating item:', error);
      res.status(500).json({ error: 'Server error creating item' });
    }
  }
);

// ----------------------------
// PUT /api/items/:id
// Update item (vendor only)
// ----------------------------
router.put(
  '/:id',
  [authMiddleware, vendorOnly],
  [
    body('name').optional().notEmpty().trim().withMessage('Name cannot be empty'),
    body('description').optional().notEmpty().trim().withMessage('Description cannot be empty'),
    body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('imageUrl').optional().notEmpty().withMessage('Image URL cannot be empty'),
    body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
  ],
  async (req, res) => {
    // Validate input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const { name, description, price, imageUrl, stock } = req.body;

      const item = await Item.findById(req.params.id);

      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }

      // Update fields
      if (name !== undefined) item.name = name;
      if (description !== undefined) item.description = description;
      if (price !== undefined) item.price = price;
      if (imageUrl !== undefined) item.imageUrl = imageUrl;
      if (stock !== undefined) item.stock = stock;

      await item.save();

      res.json({
        message: 'Item updated successfully',
        item,
      });
    } catch (error) {
      console.error('Error updating item:', error);
      res.status(500).json({ error: 'Server error updating item' });
    }
  }
);

// ----------------------------
// DELETE /api/items/:id
// Delete item (vendor only)
// ----------------------------
router.delete('/:id', [authMiddleware, vendorOnly], async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);

    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json({
      message: 'Item deleted successfully',
      item,
    });
  } catch (error) {
    console.error('Error deleting item:', error);
    res.status(500).json({ error: 'Server error deleting item' });
  }
});

// ----------------------------
// POST /api/checkout
// Process checkout and update stock
// ----------------------------
router.post(
  '/checkout',
  [
    body('items').isArray().withMessage('Items must be an array'),
    body('items.*.itemId').notEmpty().withMessage('Item ID is required'),
    body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be a positive integer'),
  ],
  async (req, res) => {
    // Validate input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const { items } = req.body;

      // Validate stock availability first
      for (const orderItem of items) {
        const item = await Item.findById(orderItem.itemId);

        if (!item) {
          return res.status(404).json({
            error: `Item ${orderItem.itemId} not found`
          });
        }

        if (item.stock < orderItem.quantity) {
          return res.status(400).json({
            error: `Insufficient stock for ${item.name}. Available: ${item.stock}, Requested: ${orderItem.quantity}`
          });
        }
      }

      // Update stock for all items
      for (const orderItem of items) {
        const item = await Item.findById(orderItem.itemId);
        const oldStock = item.stock;
        item.stock -= orderItem.quantity;
        await item.save();

        console.log(`✅ Updated stock for ${item.name}: ${oldStock} -> ${item.stock}`);
      }

      res.json({
        message: 'Checkout successful! Stock has been updated.',
        success: true,
      });
    } catch (error) {
      console.error('Error during checkout:', error);
      res.status(500).json({
        error: error.message || 'Checkout failed'
      });
    }
  }
);

module.exports = router;
