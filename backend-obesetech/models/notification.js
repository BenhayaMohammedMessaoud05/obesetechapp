// models/notification.js
const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  icon: { type: String, required: true },
  color: { type: String, required: true },
  date: { type: Date, default: Date.now },
  read: { type: Boolean, default: false }
});

// Export une fonction qui accepte une instance de DB
module.exports = (connection) => {
  return connection.model('Notification', notificationSchema);
};
