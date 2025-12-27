const nodemailer = require("nodemailer");
require("dotenv").config();

const sendOtpMail = async (toEmail, otp) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: toEmail,
      subject: "WSA App Email Verification OTP",
      html: `<p>Your OTP for email verification is: <b>${otp}</b></p>
             <p>This OTP will expire in 5 minutes.</p>`,
    };

    await transporter.sendMail(mailOptions);
    console.log(`OTP sent to ${toEmail}`);
  } catch (err) {
    console.error("Error sending OTP email:", err);
    throw new Error("Failed to send OTP email");
  }
};

module.exports = sendOtpMail;
