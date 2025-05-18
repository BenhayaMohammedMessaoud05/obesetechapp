const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { authenticateToken } = require('../middlewares/authMiddleware');

const router = express.Router();

// ✅ Route d'inscription
router.post('/signup', async (req, res) => {
  const { name, email, password, weight, bmi, height, role } = req.body;

  if (!name || !email || !password || !role) {
    return res.status(400).json({ msg: 'Nom, email, mot de passe et rôle sont obligatoires.' });
  }

  try {
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ msg: 'Utilisateur déjà existant' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      weight,
      bmi,
      height,
      role: role || 'Patient',
    });

    await newUser.save();
    res.status(201).json({ msg: 'Utilisateur créé avec succès' });
  } catch (error) {
    console.error('Erreur lors de la création du compte :', error);
    res.status(500).json({ msg: 'Erreur du serveur' });
  }
});

// ✅ Route de connexion
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ msg: 'Email et mot de passe sont requis' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Utilisateur non trouvé' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Mot de passe incorrect' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: '1h',
    });

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Erreur lors de la connexion :', error);
    res.status(500).json({ msg: 'Erreur du serveur' });
  }
});

// ✅ Route protégée : profil utilisateur
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ msg: 'Utilisateur non trouvé' });
    }

    res.json({
      name: user.name,
      email: user.email,
      role: user.role,
      weight: user.weight,
      bmi: user.bmi,
      height: user.height,
    });
  } catch (error) {
    console.error('Erreur lors de la récupération du profil :', error);
    res.status(500).json({ msg: 'Erreur du serveur' });
  }
});

console.log('Auth router ready');
module.exports = router;
