import express from 'express';
import authRoutes from './routes/auth'; // Auth route
import taskRoutes from './routes/task'; // Task route
import cors from 'cors';                // 🔁 Needed for mobile access
import 'dotenv/config';

const app = express();

// ✅ Render will assign PORT as an env var — use fallback if undefined
const PORT = process.env.PORT || 8000;

app.use(cors());              // 🔁 Allow frontend (Flutter) access
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);

app.get('/', (req, res) => {
  res.send('Welcome to my app!!!!!!!');
});

app.listen(PORT, () => {
  console.log(`✅ Server started on port ${PORT}`);
});

// import express from 'express';
// import authRoutes from './routes/auth'; // default import
// import taskRoutes from './routes/task'; // ✅ This matches your actual file
// import 'dotenv/config';


// const app = express();
// const PORT = 8000;


// app.use(express.json());

// app.use('/auth', authRoutes);     // Auth routes
// app.use('/tasks', taskRoutes);    // Task routes

// app.get('/', (req, res) => {
//   res.send('Welcome to my app!!!!!!!');
// });

// app.listen(PORT, () => {
//   console.log(`Server started on port ${PORT}.`);
// });
