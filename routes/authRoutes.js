const express = require("express");
const router = express.Router();
const User = require("../models/User");
const bcrypt = require("bcrypt");

// REGISTER USER / CREATE ACCOUNT
router.post("/signup", async (req, res) => {
    try {
        const { fname, lname, email, phone, password } = req.body;

        // Check if user already exists
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: "User already exists" });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
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

module.exports = router;
