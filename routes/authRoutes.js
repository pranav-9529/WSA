const express = require("express");
const router = express.Router();
const User = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const sendOtpMail = require("../utils/sendOtpMail");

// -------------------------------------
// SIGNUP WITH OTP
// -------------------------------------
router.post("/signup", async (req, res) => {
  const { fname, lname, email, phone, password } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ message: "User already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    const newUser = await User.create({
      fname,
      lname,
      email,
      phone,
      password: hashedPassword,
      otp,
      otpExpires: Date.now() + 5 * 60 * 1000, // 5 minutes
      isVerified: false,
    });

    await sendOtpMail(email, otp);

    res.status(201).json({
      message: "Signup successful. OTP sent to your email.",
      userId: newUser._id,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// -------------------------------------
// VERIFY EMAIL OTP
// -------------------------------------
router.post("/verify-email", async (req, res) => {
  const { email, otp } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) return res.status(404).json({ message: "User not found" });
    if (user.isVerified) return res.status(400).json({ message: "Email already verified" });
    if (user.otp !== otp || user.otpExpires < Date.now()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    user.isVerified = true;
    user.otp = null;
    user.otpExpires = null;
    await user.save();

    res.status(200).json({ message: "Email verified successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// -------------------------------------
// Resend OIP
// -------------------------------------
router.post("/resend-otp", async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: "Email is required" });
  }

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.isVerified) {
      return res.status(409).json({ message: "User already verified" });
    }

    // Prevent OTP spam
    if (user.otpExpires && user.otpExpires > Date.now()) {
      return res.status(429).json({
        message: "OTP already sent. Please wait before requesting again"
      });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    user.otp = otp;
    user.otpExpires = Date.now() + 5 * 60 * 1000; // 5 min
    await user.save();

    await sendOtpMail(email, otp);

    res.status(200).json({ message: "OTP resent successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// -------------------------------------
// LOGIN
// -------------------------------------
router.post("/login", async (req, res) => {
  const { email, phone, password } = req.body;

  try {
    if (!password) return res.status(400).json({ message: "Password is required" });
    if (!email && !phone) return res.status(400).json({ message: "Email or Phone is required" });

    const user = await User.findOne({ $or: [{ email }, { phone }] });
    if (!user) return res.status(404).json({ message: "User not found" });

    if (!user.isVerified) {
      return res.status(403).json({
        message: "Email not verified. Please verify your email first.",
        verifyRequired: true,
        userId: user._id,
        email: user.email,
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid password" });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "7d" });

    res.status(200).json({
      message: "Login successful",
      token,
      userID: user._id,
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

module.exports = router;