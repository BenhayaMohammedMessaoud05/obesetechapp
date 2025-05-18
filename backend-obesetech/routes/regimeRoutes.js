const express = require('express');
const router = express.Router();
const Regime = require('../models/regime');
const KcalTracking = require('../models/kcalTracking');
const Validation = require('../models/validation');

// Get regime for a specific day
router.get('/regime/:userId/:day', async (req, res) => {
  try {
    const { userId, day } = req.params;
    const regime = await Regime.findOne({ userId, dayIndex: parseInt(day) });
    res.json(regime || { meals: [] });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Save or update regime data (including checked items)
router.post('/regime/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { dayIndex, meals } = req.body;
    let regime = await Regime.findOne({ userId, dayIndex });
    if (regime) {
      regime.meals = meals;
      await regime.save();
    } else {
      regime = new Regime({ userId, dayIndex, meals });
      await regime.save();
    }
    res.json(regime);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get weekly kcal data
router.get('/kcal/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const kcal = await KcalTracking.findOne({ userId });
    res.json(kcal || { kcalPrescrit: [], kcalMange: [] });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update kcal data
router.post('/kcal/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { kcalPrescrit, kcalMange } = req.body;
    let kcal = await KcalTracking.findOne({ userId });
    if (kcal) {
      kcal.kcalPrescrit = kcalPrescrit;
      kcal.kcalMange = kcalMange;
      await kcal.save();
    } else {
      kcal = new KcalTracking({ userId, kcalPrescrit, kcalMange });
      await kcal.save();
    }
    res.json(kcal);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Validate a day
router.post('/validate/:userId/:day', async (req, res) => {
  try {
    const { userId, day } = req.params;
    let validation = await Validation.findOne({ userId, dayIndex: parseInt(day) });
    if (validation) {
      validation.validated = true;
      await validation.save();
    } else {
      validation = new Validation({ userId, dayIndex: parseInt(day), validated: true });
      await validation.save();
    }
    res.json(validation);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;