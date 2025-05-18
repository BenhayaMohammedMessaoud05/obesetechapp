// routes/foodRoutes.js
const express = require('express');
const router = express.Router();
const Food = require('../models/Food'); // Modèle des aliments

// Route pour ajouter des aliments
router.post('/', async (req, res) => {
  try {
    const newFood = new Food({
      name: req.body.name,
      calories: req.body.calories,
      protein: req.body.protein,
      fat: req.body.fat,
      carbohydrate: req.body.carbohydrate,
    });
    await newFood.save();
    res.status(201).json({ message: 'Aliment ajouté avec succès', data: newFood });
  } catch (err) {
    res.status(500).json({ message: 'Erreur lors de l\'ajout de l\'aliment', error: err.message });
  }
});

module.exports = router;
