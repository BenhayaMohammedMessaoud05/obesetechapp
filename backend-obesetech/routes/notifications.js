const express = require('express');
const router = express.Router();
const { getNotificationDB } = require('../db/multiMongoose');
const createNotificationModel = require('../models/notification');

// GET /api/notifications/:name
router.get('/:name', async (req, res) => {
  try {
    const db = await getNotificationDB();
    const Notification = createNotificationModel(db);
    const notifs = await Notification.find({ name: req.params.name })
      .sort({ date: -1 })
      .limit(10);
    res.json(notifs);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur: ' + err.message });
  }
});

// POST /api/notifications
router.post('/', async (req, res) => {
  try {
    const db = await getNotificationDB();
    const Notification = createNotificationModel(db);
    const notif = new Notification(req.body);
    await notif.save();
    res.status(201).json(notif);
  } catch (err) {
    res.status(400).json({ error: 'Erreur: ' + err.message });
  }
});

module.exports = router;
