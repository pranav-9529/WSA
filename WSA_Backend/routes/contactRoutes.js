const express = require("express");
const router = express.Router();
const Contact = require("../models/contact");

// Create Contact (with userID)
router.post("/create", async (req, res) => {
  try {
    const { folderID, c_name, c_phone, userID } = req.body;

    if (!folderID || !c_name || !c_phone || !userID) {
      return res.status(400).json({ success: false, message: "All fields + userID required!" });
    }

    const contact = await Contact.create({
      folderID,
      c_name,
      c_phone,
      userID
    });

    res.json({ success: true, contact });
  }
  catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get contacts of that folder for that user
router.get("/:folderId/:userID", async (req, res) => {
  try {
    const { folderId, userID } = req.params;

    const contacts = await Contact.find({ folderID: folderId, userID })
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, contacts });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error fetching contacts",
      error: error.message,
    });
  }
});

// Delete multiple contacts only of that user
router.post("/delete-multiple", async (req, res) => {
  try {
    const { ids, userID } = req.body;

    await Contact.deleteMany({ _id: { $in: ids }, userID });

    res.json({ success: true, message: "Contacts deleted" });
  } catch (error) {
    res.status(500).json({ success: false });
  }
});

module.exports = router;
