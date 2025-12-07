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
router.post("/delete-multiple/:userID/:folderID", async (req, res) => {
  try {
    const { userID, folderID } = req.params;
    const { contactIDs } = req.body;

    if (!contactIDs || !Array.isArray(contactIDs)) {
      return res.status(400).json({ success: false, message: "contactIDs array required" });
    }

    const result = await Contact.deleteMany({
      _id: { $in: contactIDs },
      userID,
      folderID
    });

    return res.json({
      success: true,
      deletedCount: result.deletedCount,
      message: `${result.deletedCount} contacts deleted`
    });

  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Search Contacts
// Example query: /search?query=John&folderID=123
router.get("/search", async (req, res) => {
    try {
        const { query, folderID } = req.query;

        if (!query) {
            return res.status(400).json({ success: false, message: "Search query is required" });
        }

        // Build search condition
        let searchCondition = {
            $or: [
                { c_name: { $regex: query, $options: "i" } }, // case-insensitive name search
                { c_phone: { $regex: query, $options: "i" } } // phone search
            ]
        };

        // If folderID provided, add it to the condition
        if (folderID) {
            searchCondition.folderID = folderID;
        }

        const contacts = await Contact.find(searchCondition);

        res.json({ success: true, contacts });
    } catch (error) {
        console.error("Error searching contacts:", error);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

module.exports = router;
