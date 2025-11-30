const express = require("express");
const router = express.Router();
const User = require("../models/User");
const bcrypt = require("bcrypt");

// Signup
router.post("/signup", async (req, res) => {
    const { fname, lname, email, phone, password } = req.body;
    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ message: "User already exists" });

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await User.create({ fname, lname, email, phone, password: hashedPassword });

        res.status(201).json({ message: "User registered successfully", userId: newUser._id });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Login
router.post("/login", async (req, res) => {
  const { email, phone, password } = req.body;

  try {
    // Check password
    if (!password) {
      return res.status(400).json({ message: "Password is required" });
    }

    // At least one of email or phone must be sent
    if (!email && !phone) {
      return res.status(400).json({ message: "Email or Phone is required" });
    }

    // Find user by email or phone
    const user = await User.findOne({
      $or: [{ email: email }, { phone: phone }]
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Compare hashed password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    // Success
    res.status(200).json({
      message: "Login successful",
      user: {
        id: user._id,
        fname: user.fname,
        lname: user.lname,
        email: user.email,
        phone: user.phone,
      },
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});




// Get all users
router.get("/all", async (req, res) => {
    try {
        const users = await User.find().select("-password");
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
