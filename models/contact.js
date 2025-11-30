const mongoose = require ("mongoose");

const contactSchema = new mongoose.Schema({
    folderID: {type: mongoose.Schema.Types.ObjectId, ref: "Folder", required: true},
    c_name: { type: String, requird: true, trim: true, unique: true },
    c_phone: { type: String, requird: true, trim: true, unique: true}
});

module.exports = mongoose.model("Contact", contactSchema);