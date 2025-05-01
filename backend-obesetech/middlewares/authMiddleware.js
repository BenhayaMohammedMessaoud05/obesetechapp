// middlewares/authMiddleware.js

const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  // Récupérer le token du header Authorization
  const token = req.header('Authorization')?.split(' ')[1]; // Supposons que le token soit dans "Authorization: Bearer <token>"

  if (!token) {
    return res.status(403).json({ msg: 'Accès refusé, token manquant' });
  }

  try {
    // Vérifier le token avec la clé secrète (assurez-vous que la clé est dans le .env)
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attacher l'utilisateur décodé à la requête
    req.user = decoded;

    // Passer au middleware suivant
    next();
  } catch (err) {
    return res.status(403).json({ msg: 'Token invalide ou expiré' });
  }
};

module.exports = { authenticateToken };
