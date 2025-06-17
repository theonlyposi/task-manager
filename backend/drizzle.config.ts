import 'dotenv/config'; // This loads environment variables from Render
import { drizzle } from 'drizzle-orm/node-postgres';
import pg from 'pg';

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool);

// // drizzle.config.ts
// import { defineConfig } from "drizzle-kit";

// export default defineConfig({
//   schema: "./src/db/schema.ts",
//   out: "./drizzle",
//   driver: "pg",
//   dbCredentials: {
//     connectionString: "postgresql://postgres:test123@localhost:5432/mydb",
//   },
// });
