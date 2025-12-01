const mongoose = require("mongoose");

const contactSchema = new mongoose.Schema({
  userID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  folderID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Folder",
    required: true
  },
  c_name: {
    type: String,
    required: true
  },
  c_phone: {
    type: String,
    required: true
  }
}, { timestamps: true });

module.exports = mongoose.model("Contact", contactSchema);
