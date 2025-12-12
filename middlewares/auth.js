const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    const token = req.header("Authorization");

    if (!token) {
      return res.status(401).json({ message: "Access Denied. No Token Provided!" });
    }

    const decoded = jwt.verify(token.replace("Bearer ", ""), process.env.JWT_SECRET);

    req.user = decoded; // contains user id
    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid Token!" });
  }
};
