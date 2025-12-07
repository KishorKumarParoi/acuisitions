import { defineConfig } from 'drizzle-kit';
import dotenv from 'dotenv';

dotenv.config();

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/models/*.js',
  out: './drizzle',
  dbCredentials: {
    url: process.env.DATABASE_URL,
  },
  migrations: {
    prefix: 'timestamp',
  },
  tablesFilter: ['acquistions_*'],
});
