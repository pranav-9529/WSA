const mongoose = require("mongoose");

const folderSchema = new mongoose.Schema({
    foldername: { type: String, required: true , trim: true, unique: true },
}, { timestamps: true });

module.exports = mongoose.model("Folder", folderSchema);
