const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ message: 'Aucun token, autorisation refusée' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.id };
    console.log('Middleware: Token verified, user ID:', req.user.id);
    next();
  } catch (err) {
    console.error('Middleware: Token verification error:', err);
    res.status(401).json({ message: 'Token invalide' });
  }
};

module.exports = { authenticateToken };
