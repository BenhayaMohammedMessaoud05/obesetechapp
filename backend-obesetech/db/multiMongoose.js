const mongoose = require('mongoose');
require('dotenv').config();

const connections = {};

const connectToDatabase = async (key, uri) => {
  if (connections[key]) return connections[key];
  const connection = await mongoose.createConnection(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  });
  connections[key] = connection;
  return connection;
};

const getNotificationDB = async () => {
  return await connectToDatabase('notifications', process.env.MONGO_URI_NOTIFICATIONS);
};

module.exports = {
  getNotificationDB
};
