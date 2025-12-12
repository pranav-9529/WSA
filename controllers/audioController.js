const Audio = require("../models/AudioModel");
const fs = require("fs");
const path = require("path");

// Upload audio
exports.uploadAudio = async (req, res) => {
  try {
    const file = req.file;
    if (!file) return res.status(400).json({ message: "No file uploaded" });

    const audio = await Audio.create({
      user: req.user._id,
      fileName: file.filename,
      filePath: file.path,
    });

    res.status(201).json(audio);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get user recordings
exports.getUserAudio = async (req, res) => {
  try {
    const clips = await Audio.find({ user: req.user._id }).sort({ uploadDate: -1 });
    res.json(clips);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Delete recording
exports.deleteAudio = async (req, res) => {
  try {
    const { id } = req.params;
    const clip = await Audio.findById(id);
    if (!clip) return res.status(404).json({ message: "Audio not found" });

    if (clip.user.toString() !== req.user._id.toString())
      return res.status(403).json({ message: "Not authorized" });

    const filePath = path.join(__dirname, "..", clip.filePath);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

    await Audio.findByIdAndDelete(id);
    res.json({ message: "Audio deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Share recording (return public URL)
exports.shareAudio = async (req, res) => {
  try {
    const { id } = req.params;
    const clip = await Audio.findById(id);
    if (!clip) return res.status(404).json({ message: "Audio not found" });

    if (clip.user.toString() !== req.user._id.toString())
      return res.status(403).json({ message: "Not authorized" });

    const publicURL = `${req.protocol}://${req.get("host")}/${clip.filePath}`;
    res.json({ url: publicURL });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
