const mongoose = require('mongoose');

// Create a dedicated connection for regime_tracker_db
const regimeDb = mongoose.createConnection(process.env.MONGO_URI_REGIME, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const validationSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  dayIndex: { type: Number, required: true, min: 0, max: 6 },
  validated: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = regimeDb.model('Validation', validationSchema);