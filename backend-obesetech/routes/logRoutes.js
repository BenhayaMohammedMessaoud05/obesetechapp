const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Log = require('../models/Log');

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

// Log a quick action
router.post('/', verifyToken, async (req, res) => {
  try {
    const { type, details } = req.body;
    const log = new Log({
      userId: req.userId,
      type,
      details,
    });
    await log.save();
    res.json({ message: 'Log added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;