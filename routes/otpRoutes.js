const express = require("express");
const router = express.Router();
const sendOtpEmail = require("../config/email");
const { saveOtp, verifyOtp } = require("../models/otpModel");

// Send OTP
router.post("/send-otp", async (req, res) => {
  const { email } = req.body;

  if (!email) return res.json({ success: false, message: "Email required" });

  const otp = Math.floor(100000 + Math.random() * 900000); // 6-digit OTP
  saveOtp(email, otp);

  try {
    await sendOtpEmail(email, otp);
    res.json({ success: true, message: "OTP sent to email" });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Verify OTP
router.post("/verify-otp", (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) return res.json({ success: false, message: "Email & OTP required" });

  const result = verifyOtp(email, otp);
  res.json(result);
});

module.exports = router;
