// Temporary in-memory store
// { "email@example.com": { otp: 123456, expires: timestamp } }

let otpStore = {};

function saveOtp(email, otp) {
  const expires = new Date().getTime() + 5 * 60 * 1000; // 5 minutes
  otpStore[email] = { otp, expires };
}

function verifyOtp(email, otp) {
  if (!otpStore[email]) return { success: false, message: "No OTP found" };

  const isExpired = new Date().getTime() > otpStore[email].expires;
  if (isExpired) {
    delete otpStore[email];
    return { success: false, message: "OTP expired" };
  }

  if (parseInt(otp) === otpStore[email].otp) {
    delete otpStore[email];
    return { success: true, message: "Email verified!" };
  } else {
    return { success: false, message: "Invalid OTP" };
  }
}

module.exports = { saveOtp, verifyOtp };
