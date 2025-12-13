const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const Recording = require('../models/recording');
const auth = require('../middlewares/auth');

const router = express.Router();

// --------------------
// Upload directory
// --------------------
const uploadDir = path.join(__dirname, '..', 'uploads');
fs.mkdirSync(uploadDir, { recursive: true });

// --------------------
// Multer setup
// --------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname) || '.wav';
    cb(null, unique + ext);
  }
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('audio/')) {
      return cb(new Error('Only audio files allowed'));
    }
    cb(null, true);
  }
});


// =================================================
// UPLOAD RECORDING
// =================================================
router.post('/upload', auth, upload.single('audio'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No audio file provided' });
    }

    const file = req.file;

    const recording = await Recording.create({
      userId: req.user.userId,
      originalName: file.originalname,
      filePath: `uploads/${file.filename}`, // no leading slash
      mimeType: file.mimetype,
      size: file.size
    });

    res.json({ message: 'Recording uploaded', recording });

  } catch (err) {
    res.status(500).json({ message: 'Upload failed', error: err.message });
  }
});


// =================================================
// FETCH USER RECORDINGS
// =================================================
router.get('/', auth, async (req, res) => {
  try {
    const recordings = await Recording
      .find({ userId: req.user.userId })
      .sort({ createdAt: -1 });

    res.json(recordings);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// =================================================
// DELETE RECORDING
// =================================================
router.delete('/:id', auth, async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id);
    if (!recording) {
      return res.status(404).json({ message: 'Recording not found' });
    }

    if (recording.userId.toString() !== req.user.userId) {
      return res.status(403).json({ message: 'Not allowed' });
    }

    const fullPath = path.join(__dirname, '..', recording.filePath);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }

    await Recording.deleteOne({ _id: recording._id });

    res.json({ message: 'Recording deleted' });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// =================================================
// SHARE RECORDING (PUBLIC LINK)
// =================================================
router.post('/:id/share', auth, async (req, res) => {
  try {
    const recording = await Recording.findById(req.params.id);
    if (!recording) {
      return res.status(404).json({ message: 'Recording not found' });
    }

    if (recording.userId.toString() !== req.user.userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    recording.shareToken = uuidv4();
    recording.shareExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    await recording.save();

    const url = `${req.protocol}://${req.get('host')}/api/recordings/shared/${recording.shareToken}`;

    res.json({
      shareUrl: url,
      expiresAt: recording.shareExpiresAt
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// =================================================
// ACCESS SHARED RECORDING (NO AUTH)
// =================================================
router.get('/shared/:token', async (req, res) => {
  try {
    const rec = await Recording.findOne({ shareToken: req.params.token });
    if (!rec) {
      return res.status(404).json({ message: 'Invalid link' });
    }

    if (rec.shareExpiresAt < new Date()) {
      return res.status(410).json({ message: 'Link expired' });
    }

    const fullPath = path.join(__dirname, '..', rec.filePath);
    if (!fs.existsSync(fullPath)) {
      return res.status(404).json({ message: 'File missing' });
    }

    res.sendFile(fullPath);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
