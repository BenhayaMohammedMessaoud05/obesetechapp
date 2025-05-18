const mongoose = require('mongoose');

// Create a dedicated connection for regime_tracker_db
const regimeDb = mongoose.createConnection(process.env.MONGO_URI_REGIME, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const regimeSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  dayIndex: { type: Number, required: true, min: 0, max: 6 },
  kcalPrescrit: { type: Number, required: true, default: 0 },
  kcalMange: { type: Number, required: true, default: 0 },
  validated: { type: Boolean, default: false },
  meals: [{
    titre: { type: String, required: true },
    aliments: [{
      nom: { type: String, required: true },
      kcal: { type: Number, required: true },
      checked: { type: Boolean, default: false }
    }]
  }]
}, { timestamps: true });

// Unique index to prevent duplicate entries for the same user and day
regimeSchema.index({ userId: 1, dayIndex: 1 }, { unique: true });

module.exports = regimeDb.model('Regime', regimeSchema);