const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");

dotenv.config();
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// DB Connection
connectDB();

// Routes
app.use("/api/auth", require("./routes/authRoutes"));

const emailOtpRoutes = require("./routes/otpRoutes");
app.use("/api/otp", emailOtpRoutes);

const folderRoutes = require("./routes/folderRoutes");
app.use("/api/folder", folderRoutes);

const contactRoutes = require("./routes/contactRoutes");
app.use("/api/contact", contactRoutes);

const videoRoutes = require("./routes/videoRoutes");
app.use("/api/video", videoRoutes);

const recordingRoutes = require('./routes/recordingsRoutes');
 app.use('/api/recordings', recordingRoutes);


// Root endpoint
app.get("/", (req, res) => {
    res.send("WSA backend server is live!");
});

// Use dynamic port for Render deployment
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
