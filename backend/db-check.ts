// db-check.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { users } from './src/db/schema'; // Update the path if different

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:test123@localhost:5432/mydb',
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
