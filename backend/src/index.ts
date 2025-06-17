import express from 'express';
import authRoutes from './routes/auth'; // default import
import taskRoutes from './routes/task'; // ✅ This matches your actual file
import 'dotenv/config';


const app = express();
// const PORT = 8000;
// const PORT = process.env.PORT || 8000;
const PORT = process.env.PORT || 10000;


app.use(express.json());

app.use('/auth', authRoutes);     // Auth routes
app.use('/tasks', taskRoutes);    // Task routes

app.get('/', (req, res) => {
  res.send('Welcome to my app!!!!!!!');
});

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}.`);
});
