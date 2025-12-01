const mongoose = require("mongoose");

const folderSchema = new mongoose.Schema({
  userID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  foldername: {
    type: String,
    required: true
  }
}, { timestamps: true });

module.exports = mongoose.model("Folder", folderSchema);
