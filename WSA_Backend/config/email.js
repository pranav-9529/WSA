const nodemailer = require("nodemailer");
const { google } = require("googleapis");
require("dotenv").config(); // load credentials from .env

// Use environment variables for safety
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = process.env.REDIRECT_URI;
const REFRESH_TOKEN = process.env.REFRESH_TOKEN;
const SENDER_EMAIL = process.env.SENDER_EMAIL; // your Gmail account

// Create OAuth2 client
const oAuth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI
);

oAuth2Client.setCredentials({ refresh_token: REFRESH_TOKEN });

async function sendOtpEmail(toEmail, otp) {
  try {
    // Get access token
    const { token: accessToken } = await oAuth2Client.getAccessToken();

    // Create transporter
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        type: "OAuth2",
        user: SENDER_EMAIL,
        clientId: CLIENT_ID,
        clientSecret: CLIENT_SECRET,
        refreshToken: REFRESH_TOKEN,
        accessToken: accessToken,
      },
    });

    // Mail options
    const mailOptions = {
      from: `WSA App <${SENDER_EMAIL}>`,
      to: toEmail,
      subject: "WSA OTP Verification",
      text: `Your OTP is ${otp}. It is valid for 5 minutes.`,
    };

    // Send email
    const result = await transporter.sendMail(mailOptions);
    console.log("OTP sent to:", toEmail);
    return result;
  } catch (error) {
    console.error("Error sending OTP email:", error.response || error);
    throw error;
  }
}

module.exports = sendOtpEmail;
