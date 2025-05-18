const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Activity = require('../models/Activity');

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

// Get activity for today
router.get('/', verifyToken, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const activity = await Activity.findOne({
      userId: req.userId,
      date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) },
    });
    const weeklyActivities = await Activity.find({
      userId: req.userId,
      date: {
        $gte: new Date(today.getTime() - 6 * 24 * 60 * 60 * 1000),
        $lte: today,
      },
    }).sort({ date: 1 });
    const weeklySteps = Array(7).fill(0);
    weeklyActivities.forEach((act) => {
      const dayIndex = Math.floor((today.getTime() - act.date.getTime()) / (24 * 60 * 60 * 1000));
      if (dayIndex >= 0 && dayIndex < 7) weeklySteps[6 - dayIndex] = act.steps;
    });
    res.json({
      steps: activity?.steps || 0,
      calories: activity?.calories || 0,
      kilometers: activity?.kilometers || 0,
      activeMinutes: activity?.activeMinutes || 0,
      goalPercent: activity?.goalPercent || 0,
      weeklySteps,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update or create activity for today
router.post('/', verifyToken, async (req, res) => {
  try {
    const { steps, calories, kilometers, activeMinutes, goalPercent } = req.body;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let activity = await Activity.findOne({
      userId: req.userId,
      date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) },
    });
    if (activity) {
      activity.steps = steps;
      activity.calories = calories;
      activity.kilometers = kilometers;
      activity.activeMinutes = activeMinutes;
      activity.goalPercent = goalPercent;
    } else {
      activity = new Activity({
        userId: req.userId,
        date: today,
        steps,
        calories,
        kilometers,
        activeMinutes,
        goalPercent,
      });
    }
    await activity.save();
    res.json({ message: 'Activity updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;