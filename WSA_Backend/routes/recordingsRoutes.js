const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const Recording = require('../models/recording');
const auth = require('../middleware/auth');

const router = express.Router();

const uploadDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

// multer storage for audio
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const id = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname) || '.wav';
    cb(null, id + ext);
  },
});
const upload = multer({ storage });


// -----------------------------------------------
// UPLOAD RECORDING
// -----------------------------------------------
router.post('/upload', auth, upload.single('audio'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No file found!' });

    const file = req.file;

    const newRecording = await Recording.create({
      userId: req.user.userId,
      originalName: file.originalname,
      filePath: `/uploads/${file.filename}`,
      mimeType: file.mimetype,
      size: file.size,
    });

    res.json({ message: 'Recording uploaded', recording: newRecording });
  } catch (err) {
    res.status(500).json({ message: 'Upload failed', error: err.message });
  }
});


// -----------------------------------------------
// FETCH USER RECORDINGS
// -----------------------------------------------
router.get('/', auth, async (req, res) => {
  try {
    const list = await Recording.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// -----------------------------------------------
// DELETE RECORDING
// -----------------------------------------------
router.delete('/:id', auth, async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id);
    if (!recording) return res.status(404).json({ message: 'Not found' });

    if (recording.userId.toString() !== req.user.userId)
      return res.status(403).json({ message: 'You do not own this file' });

    const fullPath = path.join(__dirname, '..', recording.filePath);

    if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
    await recording.remove();

    res.json({ message: 'Recording deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// -----------------------------------------------
// SHARE RECORDING (PUBLIC TOKEN)
// -----------------------------------------------
router.post('/:id/share', auth, async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id);
    if (!recording) return res.status(404).json({ message: 'Not found' });

    if (recording.userId.toString() !== req.user.userId)
      return res.status(403).json({ message: 'Unauthorized' });

    const token = uuidv4();
    const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    recording.shareToken = token;
    recording.shareExpiresAt = expiry;
    await recording.save();

    const link = `${req.protocol}://${req.get('host')}/api/recordings/shared/${token}`;

    res.json({ shareUrl: link, expiresAt: expiry });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// -----------------------------------------------
// ACCESS SHARED RECORDING (NO LOGIN REQUIRED)
// -----------------------------------------------
router.get('/shared/:token', async (req, res) => {
  try {
    const rec = await Recording.findOne({ shareToken: req.params.token });
    if (!rec) return res.status(404).json({ message: 'Invalid token' });

    if (rec.shareExpiresAt < new Date())
      return res.status(410).json({ message: 'Link expired' });

    const fullFile = path.join(__dirname, '..', rec.filePath);
    if (!fs.existsSync(fullFile))
      return res.status(404).json({ message: 'File missing' });

    res.sendFile(fullFile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;
