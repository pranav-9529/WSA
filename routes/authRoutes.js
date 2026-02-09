
const express = require("express");
const router = express.Router();
const User = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
require("dotenv").config();

// -------------------------------------
//              SIGNUP
// -------------------------------------
router.post("/signup", async (req, res) => {
  const { fname, lname, email, phone, password } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ message: "User already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await User.create({
      fname,
      lname,
      email,
      phone,
      password: hashedPassword,
    });

    res
      .status(201)
      .json({ message: "User registered successfully", userId: newUser._id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// -------------------------------------
//              LOGIN
// -------------------------------------
router.post("/login", async (req, res) => {
  const { email, phone, password } = req.body;

  try {
    if (!password) {
      return res.status(400).json({ message: "Password is required" });
    }

    if (!email && !phone) {
      return res.status(400).json({ message: "Email or Phone is required" });
    }

    // Find user by email or phone
    const user = await User.findOne({
      $or: [{ email: email }, { phone: phone }],
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    // ************ CREATE JWT TOKEN ************
    const token = jwt.sign(
      { id: user._id }, 
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    // Success Response
    res.status(200).json({
      message: "Login successful",
      token,            // <-- IMPORTANT
      userID: user._id, // <-- IMPORTANT
      user: {
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

// -------------------------------------
//        GET ALL USERS  (not protected)
// -------------------------------------
router.get("/all", async (req, res) => {
  try {
    const users = await User.find().select("-password");
    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//--------------name-update----------------
router.put('/update-name', auth, async (req, res) => {
  try {
    const { fname } = req.body;

    if (!fname || fname.trim().length < 2) {
      return res.status(400).json({ message: "Invalid name" });
    }

    await User.findByIdAndUpdate(
      req.userId,      // comes from JWT
      { fname: fname },
      { new: true }
    );

    res.json({ message: "Name updated successfully" });
  } catch (err) {
    res.status(500).json({ message: "Failed to update name" });
  }
});


module.exports = router;
