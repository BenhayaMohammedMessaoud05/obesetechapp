const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  duration: { type: String, required: true },
  intensity: { type: String, required: true },
  loggedAt: { type: Date, default: Date.now },
});

workoutSchema.index({ userId: 1, loggedAt: -1 });

module.exports = mongoose.model('Workout', workoutSchema);