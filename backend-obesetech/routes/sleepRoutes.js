const express = require('express');
const { authenticateToken } = require('../middlewares/authMiddleware');
const mongoose = require('mongoose');

const router = express.Router();

// Sleep Schema
const sleepSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
  percent: { type: Number, default: 0.78 },
  deep: { type: String, default: '2h 15m' },
  rem: { type: String, default: '1h 45m' },
  light: { type: String, default: '3h 30m' },
  bedtime: { type: String, default: '10:30 PM' },
  wakeup: { type: String, default: '7:00 AM' },
  createdAt: { type: Date, default: Date.now },
});

const Sleep = mongoose.model('Sleep', sleepSchema);

// Get Sleep Data
router.get('/', authenticateToken, async (req, res) => {
  try {
    const sleep = await Sleep.findOne({ userId: req.user.id }).sort({ createdAt: -1 });
    if (!sleep) {
      return res.json({
        percent: 0.78,
        deep: '2h 15m',
        rem: '1h 45m',
        light: '3h 30m',
        bedtime: '10:30 PM',
        wakeup: '7:00 AM',
      });
    }
    res.json(sleep);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

// Update Sleep Session
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { action } = req.body;
    if (!['start', 'end'].includes(action)) {
      return res.status(400).json({ msg: 'Action invalide' });
    }
    const sleepData = {
      userId: req.user.id,
      percent: action === 'start' ? 0.78 : 0.80,
      deep: action === 'start' ? '2h 15m' : '2h 30m',
      rem: action === 'start' ? '1h 45m' : '2h 00m',
      light: action === 'start' ? '3h 30m' : '3h 45m',
      bedtime: '10:30 PM',
      wakeup: '7:00 AM',
    };
    const sleep = new Sleep(sleepData);
    await sleep.save();
    res.json(sleep);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
});

module.exports = router;