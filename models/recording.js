const mongoose = require('mongoose');

const recordingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  originalName: String,
  filePath: String,
  mimeType: String,
  size: Number,

  shareToken: String,
  shareExpiresAt: Date
}, { timestamps: true });

module.exports = mongoose.model('Recording', recordingSchema);
