const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Item = require('../models/Item');
const { authMiddleware, vendorOnly } = require('../middleware/auth');

// ----------------------------
// Create a new order (customers)
// ----------------------------
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { itemId, quantity } = req.body;

    // Validate input
    if (!itemId || !quantity || quantity < 1) {
      return res.status(400).json({ error: 'Invalid order data' });
    }

    // Check if item exists and has enough stock
    const item = await Item.findById(itemId);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    if (item.stock < quantity) {
      return res.status(400).json({ error: 'Insufficient stock' });
    }

    // Create order
    const order = new Order({
      customer: req.user._id,
      item: itemId,
      quantity,
    });

    await order.save();

    // Reduce item stock
    item.stock -= quantity;
    await item.save();

    // Populate order with customer and item details
    await order.populate('customer', 'email role');
    await order.populate('item');

    res.status(201).json(order);
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// ----------------------------
// Get all orders
// Vendors see all orders, customers see only their own
// ----------------------------
router.get('/', authMiddleware, async (req, res) => {
  try {
    let orders;

    if (req.user.role === 'vendor') {
      // Vendors see all orders
      orders = await Order.find()
        .populate('customer', 'email role')
        .populate('item')
        .sort({ createdAt: -1 }); // Most recent first
    } else {
      // Customers see only their orders
      orders = await Order.find({ customer: req.user._id })
        .populate('item')
        .sort({ createdAt: -1 });
    }

    res.json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// ----------------------------
// Get single order by ID
// ----------------------------
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('customer', 'email role')
      .populate('item');

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Check authorization: vendors can see all, customers can only see their own
    if (req.user.role !== 'vendor' && order.customer._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    res.json(order);
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

// ----------------------------
// Update order status (vendors only)
// ----------------------------
router.patch('/:id', authMiddleware, vendorOnly, async (req, res) => {
  try {
    const { status } = req.body;

    if (!['pending', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    )
      .populate('customer', 'email role')
      .populate('item');

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(order);
  } catch (error) {
    console.error('Error updating order:', error);
    res.status(500).json({ error: 'Failed to update order' });
  }
});

module.exports = router;
