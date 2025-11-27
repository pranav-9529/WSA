const express = require("express");
const app = express();
const mongoose = require("mongoose");

mongoose.connect("mongodb+srv://women_safety_app:WSA9834@wsa.sf5h6v3.mongodb.net/WSA")
.then(() => console.log("Connected to MongoDB"))
.catch((err) => console.error("Could not connect to MongoDB...", err));

app.use(express.json());

app.get("/", (req, res) => {
    res.send("Welcome to Women Safety App Server");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

const authRoutes = require("./routes/authRoutes");
app.use("/api/auth", authRoutes);
