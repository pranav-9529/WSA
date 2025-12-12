const mongoose = require('mongoose');

const RecordingSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  originalName: { type: String },
  filePath: { type: String, required: true },
  mimeType: { type: String },
  size: { type: Number },
  createdAt: { type: Date, default: Date.now },
  // Share features
  shareToken: { type: String, index: true, sparse: true },
  shareExpiresAt: { type: Date, default: null }
});

module.exports = mongoose.model('Recording', RecordingSchema);
