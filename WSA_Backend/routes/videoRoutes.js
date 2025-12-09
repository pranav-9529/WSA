const express = require("express");
const router = express.Router();
const Video = require("../models/video");

// GET all videos
router.get("/video", async (req, res) => {
  try {
    const videos = await Video.find().sort({ createdAt: -1 });
    res.json({ videos });
  } catch (err) {
    res.status(500).json({ message: "Server Error" });
  }
});

// POST a new video
router.post("/video", async (req, res) => {
  const { title, url, thumbnail, category } = req.body;
  try {
    const newVideo = new Video({ title, url, thumbnail, category });
    await newVideo.save();
    res.status(201).json({ message: "Video added", video: newVideo });
  } catch (err) {
    res.status(400).json({ message: "Invalid data" });
  }
});

module.exports = router;
