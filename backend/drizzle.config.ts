import type { Config } from "drizzle-kit";
import * as dotenv from "dotenv";
dotenv.config();

export default {
  schema: "./src/db/schema.ts",  // update if your path differs
  out: "./drizzle",
  driver: "pg",
  dbCredentials: {
    connectionString: process.env.DATABASE_URL + "?sslmode=require",
  },
} satisfies Config;


// import { defineConfig } from 'drizzle-kit';
// import * as dotenv from 'dotenv';

// dotenv.config();

// export default defineConfig({
//   schema: './src/db/schema.ts',
//   out: './drizzle',
//   driver: 'pg',
//   dbCredentials: {
//     connectionString: process.env.DATABASE_URL!,
//   },
// });


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
