const mongoose = require('mongoose');

const logSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, required: true }, // e.g., 'water', 'food'
  details: { type: String, required: true },
  loggedAt: { type: Date, default: Date.now },
});

logSchema.index({ userId: 1, loggedAt: -1 });

module.exports = mongoose.model('Log', logSchema);