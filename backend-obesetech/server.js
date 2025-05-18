require('dotenv').config(); 
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const achievementRoutes = require('./routes/achievementRoutes');
const activityRoutes = require('./routes/activityRoutes');
const workoutRoutes = require('./routes/workoutRoutes');
const logRoutes = require('./routes/logRoutes');
const sleepRoutes = require('./routes/sleepRoutes');
const notificationRoutes = require('./routes/notifications');
const foodRoutes = require('./routes/foodRoutes');
const productRoutes = require('./routes/products');

// Config dotenv
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection (Updated to avoid deprecated options)
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log(err));

// Use routes
app.use('/api/auth', authRoutes); 
app.use('/api/user', userRoutes);
app.use('/api/achievements', achievementRoutes);
app.use('/api/activity', activityRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/logs', logRoutes);
app.use('/api/sleep', sleepRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/products', productRoutes);

// Start Server
const PORT = process.env.PORT || 2000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
