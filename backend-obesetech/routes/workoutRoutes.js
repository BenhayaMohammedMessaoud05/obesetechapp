const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Workout = require('../models/Workout');
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

// Get workouts and achievements
router.get('/', verifyToken, async (req, res) => {
  try {
    const workouts = await Workout.find({ userId: req.userId }).sort({ loggedAt: -1 });
    const achievements = await Achievement.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json({
      workouts,
      achievements,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Log a workout
router.post('/', verifyToken, async (req, res) => {
  try {
    const { title, description, duration, intensity } = req.body;
    const workout = new Workout({
      userId: req.userId,
      title,
      description,
      duration,
      intensity,
    });
    await workout.save();
    res.json({ message: 'Workout logged' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;