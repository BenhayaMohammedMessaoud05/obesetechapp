const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Achievement = require('../models/Achievement');

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

// Get achievements
router.get('/', verifyToken, async (req, res) => {
  try {
    const achievements = await Achievement.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json(achievements);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add achievement
router.post('/', verifyToken, async (req, res) => {
  try {
    const { title, description } = req.body;
    const achievement = new Achievement({
      userId: req.userId,
      title,
      description,
    });
    await achievement.save();
    res.json({ message: 'Achievement added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;