const express = require("express");
const router = express.Router();
const User = require("../models/User");
const bcrypt = require("bcrypt");

// --------------------
// REGISTER USER
// --------------------
router.post("/signup", async (req, res) => {
    try {
        const { fname, lname, email, phone, password } = req.body;

        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: "User already exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await User.create({
            fname,
            lname,
            email,
            phone,
            password: hashedPassword
        });

        res.status(201).json({
            message: "User registered successfully",
            userId: newUser._id
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --------------------
// GET ALL USERS
// --------------------
router.get("/all", async (req, res) => {
  try {
    const users = await User.find().select("-password"); // exclude password
    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
