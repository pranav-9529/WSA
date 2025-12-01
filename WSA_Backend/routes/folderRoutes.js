const express = require("express");
const router = express.Router();
const Folder = require("../models/folder");
const Contact = require("../models/contact");

// Create Folder (with userID)
router.post("/create", async (req, res) => {
  try {
    const { foldername, userID } = req.body;

    if (!foldername || !userID) {
      return res.status(400).json({ success: false, message: "Folder name and userID required!" });
    }

    const folder = await Folder.create({ foldername, userID });

    res.json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET ALL folders of that user
router.get("/all/:userID", async (req, res) => {
  try {
    const folders = await Folder.find({ userID: req.params.userID })
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, folders });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error fetching folders",
      error: error.message,
    });
  }
});

// DELETE folder + its contacts
router.delete("/delete/:id/:userID", async (req, res) => {
  try {
    const { id, userID } = req.params;

    const folder = await Folder.findOneAndDelete({ _id: id, userID });

    if (!folder) {
      return res.status(404).json({ success: false, message: "Folder not found" });
    }

    await Contact.deleteMany({ folderID: id, userID });

    res.json({
      success: true,
      message: "Folder and its contacts deleted"
    });

  } catch (error) {
    res.status(500).json({ success: false });
  }
});

module.exports = router;
