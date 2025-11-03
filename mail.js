// mailer.js
const nodemailer = require('nodemailer');

/**
 * Send an email using Gmail SMTP.
 * @param {string} to - Recipient email address.
 * @param {string} subject - Email subject.
 * @param {string} text - Plain text content.
 * @param {string} html - Optional HTML content.
 */
async function sendMail(to, subject, text, html = '') {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER, // from your .env
        pass: process.env.EMAIL_PASS, // app password
      },
    });

    const mailOptions = {
      from: `"Your App" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      text,
      html,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ Mail sent to ${to}: ${info.messageId}`);
    return info;
  } catch (error) {
    console.error('❌ Error sending mail:', error);
    throw error;
  }
}

// ✅ Export function
module.exports = { sendMail };
