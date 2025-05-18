require('dotenv').config(); // à placer en haut du fichier
const mongoose = require('mongoose');

const foodDb = mongoose.createConnection(process.env.MONGO_URI_FOOD, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const foodSchema = new mongoose.Schema({
  name: String,
  calories: Number,
  protein: Number,
  fat: Number,
  carbohydrates: Number,
  // etc.
});

const Food = foodDb.model('Food', foodSchema);
module.exports = Food;
