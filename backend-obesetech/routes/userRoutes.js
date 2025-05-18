const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ error: 'Invalid token' });
    req.userId = decoded.userId;
    next();
  });
};

// Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('name email weight bmi height role');
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update user profile
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { name, email, weight, bmi, height } = req.body;
    const user = await User.findByIdAndUpdate(
      req.userId,
      { name, email, weight, bmi, height },
      { new: true, runValidators: true }
    );
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'Profile updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Search users
router.get('/search', verifyToken, async (req, res) => {
  try {
    const query = req.query.query || '';
    const users = await User.find({
      name: { $regex: query, $options: 'i' },
      _id: { $ne: req.userId },
      role: { $in: ['Doctor', 'Coach', 'Nutritionist'] }, // Adjust roles as needed
    }).select('name email role');
    res.json(users.map(user => ({
      name: user.name,
      role: user.role,
      email: user.email,
    })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;