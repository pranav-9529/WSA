const express = require("express");
const router = express.Router();
const Folder = require("../models/folder");

// Create Folder
router.post("/create", async (req, res) => {
    try {
        const { foldername } = req.body;

        if (!foldername) {
        return res.status(400).json({ success: false, message: "Folder name required" });
        }
        const folder = await Folder.create({ foldername });

        res.json({ success: true, folder});
    }
     catch (error) {
        res.status(500).json({ success: false, error: error.message});
    }
    
})

// GET ALL FOLDERS
router.get("/all", async (req, res) => {
  try {
    const folders = await Folder.find().sort({ createdAt: -1 });
    return res.status(200).json({
      success: true,
      folders,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error while fetching folders",
      error: error.message,
    });
  }
});

module.exports = router;