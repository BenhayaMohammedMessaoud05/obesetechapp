const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  
  name: { type: String, required: true }, // Added for frontend compatibility
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  weight: { type: Number },
  bmi: { type: Number },
  height: { type: Number },
  role: { type: String, default: 'Patient' },
  createdAt: { type: Date, default: Date.now },
});

// Indexes for performance
userSchema.index({ email: 1 });

module.exports = mongoose.model('User', userSchema);