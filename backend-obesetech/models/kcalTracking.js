const mongoose = require('mongoose');

// Create a dedicated connection for regime_tracker_db
const regimeDb = mongoose.createConnection(process.env.MONGO_URI_REGIME, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const kcalTrackingSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  kcalPrescrit: [{ type: Number, required: true }],
  kcalMange: [{ type: Number, required: true }]
}, { timestamps: true });

module.exports = regimeDb.model('KcalTracking', kcalTrackingSchema);