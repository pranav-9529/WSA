const express = require("express");
const router = express.Router();
const User = require("../models/User");

// UPDATE FIRST & LAST NAME USING EMAIL
router.put("/update-name", async (req, res) => {
  try {
    const { email, fname, lname } = req.body;

    if (!email || !fname || !lname) {
      return res.status(400).json({
        message: "Email, first name and last name are required",
      });
    }

    const user = await User.findOneAndUpdate(
      { email },
      { fname, lname },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      message: "Name updated successfully",
      fname: user.fname,
      lname: user.lname,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
