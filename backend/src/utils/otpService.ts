import nodemailer from "nodemailer";
import otpGenerator from "otp-generator";

const otpStore = new Map<string, { otp: string; expiresAt: number }>();

export function generateAndStoreOtp(email: string): string {
  const otp = otpGenerator.generate(6, { digits: true });
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes
  otpStore.set(email, { otp, expiresAt });
  return otp;
}

export async function sendOtpEmail(email: string, otp: string) {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "your_email@gmail.com",
      pass: "your_app_password", // use App Password if Gmail
    },
  });

  await transporter.sendMail({
    from: "your_email@gmail.com",
    to: email,
    subject: "Your OTP Code",
    text: `Your OTP is ${otp}. It will expire in 5 minutes.`,
  });
}

export function verifyOtp(email: string, inputOtp: string): boolean {
  const record = otpStore.get(email);
  if (!record) return false;
  if (record.otp !== inputOtp || Date.now() > record.expiresAt) {
    otpStore.delete(email);
    return false;
  }
  otpStore.delete(email); // One-time use
  return true;
}
