import jwt from 'jsonwebtoken';

const getSecretKey = () => {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    console.error('CRITICAL: JWT_SECRET environment variable is not defined!');
  }
  return secret || 'insecure-fallback-dev-secret';
};

export const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ error: 'Access denied: No authorization header provided.' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Access denied: Malformed authorization header. Expected "Bearer <token>".' });
  }

  const token = parts[1];
  if (!token) {
    return res.status(401).json({ error: 'Access denied: No token provided.' });
  }

  jwt.verify(token, getSecretKey(), (err, decoded) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Unauthorized: Token has expired. Please sign in again.' });
      }
      return res.status(401).json({ error: 'Unauthorized: Invalid authentication token.' });
    }
    req.userId = decoded.id;
    req.userRole = decoded.role;
    req.userEmail = decoded.email;
    next();
  });
};

export const requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.userRole) {
      return res.status(403).json({ error: 'Access forbidden: Role information missing.' });
    }
    if (!allowedRoles.includes(req.userRole)) {
      return res.status(403).json({
        error: `Access forbidden: Required role (${allowedRoles.join(' or ')}), current role: ${req.userRole}`
      });
    }
    next();
  };
};
