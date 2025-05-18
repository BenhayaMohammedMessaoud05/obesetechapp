
const mongoose = require('mongoose');

// Create a dedicated connection for marketplacebd
const marketplaceDb = mongoose.createConnection(process.env.MONGO_URI_MARKETPLACE, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Log connection status


const productSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  imageUrl: {
    type: String,
    required: true,
  },
}, {
  timestamps: true,
});

// Define the Product model on the marketplacebd connection
const Product = marketplaceDb.model('Product', productSchema);

module.exports = Product;