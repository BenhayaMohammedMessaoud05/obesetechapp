const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  steps: { type: Number, default: 0 },
  calories: { type: Number, default: 0 },
  kilometers: { type: Number, default: 0 },
  activeMinutes: { type: Number, default: 0 },
  goalPercent: { type: Number, default: 0 },
});

activitySchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('Activity', activitySchema);