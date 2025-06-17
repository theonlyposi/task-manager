import express from 'express';
import authRoutes from './routes/auth'; // default import
import taskRoutes from './routes/task'; // ✅ This matches your actual file

const app = express();
const PORT = 8000;

app.use(express.json());

app.use('/auth', authRoutes);     // Auth routes
app.use('/tasks', taskRoutes);    // Task routes

app.get('/', (req, res) => {
  res.send('Welcome to my app!!!!!!!');
});

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}.`);
});

// import express from "express";
// import authRouter from "./routes/auth";
// import taskRouter from "./routes/task";

// const app = express();

// // Middleware
// app.use(express.json());

// // Routes
// app.use("/auth", authRouter);
// app.use("/tasks", taskRouter);

// app.get("/", (req, res) => {
//   res.send("Welcome to my app!!!!!!!");
// });

// // ✅ FIX: Bind to 0.0.0.0 so Docker can expose it
// app.listen(8000, '0.0.0.0', () => {
//   console.log("Server started on port 8000");
// });
