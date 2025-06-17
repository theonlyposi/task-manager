import { Router, RequestHandler } from "express";
import { db } from "../db";
import { NewUser, users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth";
import nodemailer from "nodemailer";
import otpGenerator from "otp-generator";

const authRouter = Router();
const otpStore = new Map<string, string>(); // email -> otp

interface RequestOtpBody {
  email: string;
}

interface VerifyOtpSignupBody {
  name: string;
  email: string;
  password: string;
  otp: string;
}

interface LoginBody {
  email: string;
  password: string;
}

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.OTP_EMAIL,
    pass: process.env.OTP_EMAIL_PASSWORD,
  },
});

const requestOtpHandler: RequestHandler<{}, {}, RequestOtpBody> = async (req, res) => {
  const { email } = req.body;

  const existingUser = await db.select().from(users).where(eq(users.email, email));
  if (existingUser.length > 0) {
    res.status(400).json({ error: "User with this email already exists!" });
    return;
  }

  const otp = otpGenerator.generate(6, {
    digits: true,
    upperCaseAlphabets: false,
    lowerCaseAlphabets: false,
    specialChars: false,
  });

  otpStore.set(email, otp);

  await transporter.sendMail({
    from: process.env.OTP_EMAIL,
    to: email,
    subject: "Your Signup OTP",
    text: `Your OTP for signup is: ${otp}`,
  });

  res.status(200).json({ message: "OTP sent to email" });
};

const verifyOtpAndSignupHandler: RequestHandler<{}, {}, VerifyOtpSignupBody> = async (req, res) => {
  const { name, email, password, otp } = req.body;

  const savedOtp = otpStore.get(email);
  if (!savedOtp || savedOtp !== otp) {
    res.status(400).json({ error: "Invalid or expired OTP" });
    return;
  }

  const hashedPassword = await bcryptjs.hash(password, 8);
  const newUser: NewUser = { name, email, password: hashedPassword };

  const [user] = await db.insert(users).values(newUser).returning();
  otpStore.delete(email);

  res.status(201).json(user);
};

const loginHandler: RequestHandler<{}, {}, LoginBody> = async (req, res) => {
  const { email, password } = req.body;

  const [existingUser] = await db.select().from(users).where(eq(users.email, email));
  if (!existingUser) {
    res.status(400).json({ error: "User with this email does not exist!" });
    return;
  }

  const isMatch = await bcryptjs.compare(password, existingUser.password);
  if (!isMatch) {
    res.status(400).json({ error: "Incorrect password!" });
    return;
  }

  const token = jwt.sign({ id: existingUser.id }, "passwordKey");

  res.status(200).json({
    message: "Login successful",
    user: {
      id: existingUser.id,
      name: existingUser.name,
      email: existingUser.email,
    },
    token,
  });
};

const tokenIsValidHandler: RequestHandler = async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      res.json(false);
      return;
    }

    const verified = jwt.verify(token, "passwordKey") as { id: string };
    const [user] = await db.select().from(users).where(eq(users.id, verified.id));
    if (!user) {
      res.json(false);
      return;
    }

    res.json(true);
  } catch {
    res.status(500).json(false);
  }
};

const getUserHandler: RequestHandler = async (req: any, res) => {
  try {
    const userId = (req as AuthRequest).user;
    const token = (req as AuthRequest).token;

    if (!userId) {
      res.status(401).json({ error: "User not found!" });
      return;
    }

    const [user] = await db.select().from(users).where(eq(users.id, userId));
    res.json({ ...user, token });
  } catch {
    res.status(500).json(false);
  }
};

// Route bindings
authRouter.post("/signup/request-otp", requestOtpHandler);
authRouter.post("/signup/verify-otp", verifyOtpAndSignupHandler);
authRouter.post("/login", loginHandler);
authRouter.post("/tokenIsValid", tokenIsValidHandler);
authRouter.get("/", auth, getUserHandler);

export default authRouter;
