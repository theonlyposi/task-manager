// db-check.ts

import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import { users } from './src/db/schema'; // ✅ Adjust if your schema path is different

dotenv.config(); // Load .env

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Required for Render DB
  },
});

const db = drizzle(pool);

async function check() {
  try {
    const allUsers = await db.select().from(users);
    console.log('✅ Connected to DB. Users:', allUsers);
    process.exit(0);
  } catch (err) {
    console.error('❌ DB Connection Failed:', err);
    process.exit(1);
  }
}

check();
