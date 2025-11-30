const express = require("express");
const router = express.Router();
const Contact = require("../models/contact");

//Create Contact
router.post("/create", async (req, res) => {
    try {
        const { folderID, c_name, c_phone } = req.body;

        if (!folderID || !c_name || !c_phone) {
            return res.status(400).json({ success: false, message: "All fields are required !"});
        }

        const contact = await Contact.create({
      folderID,
      c_name,
      c_phone,
    });

    res.json({ success: true, contact });
    }
    catch (error) {
        res.status(500).json({ success: false, error: error.message});
    }
})

// GET CONTACTS OF A SPECIFIC FOLDER
router.get("/:folderId", async (req, res) => {
  try {
    const { folderId } = req.params;

    const contacts = await Contact.find({ folderID: folderId }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      contacts,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error while fetching contacts",
      error: error.message,
    });
  }
});


module.exports = router;