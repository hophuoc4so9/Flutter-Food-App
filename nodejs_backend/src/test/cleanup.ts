import mongoose from 'mongoose';
import dotenv from 'dotenv';
import UserModel from '../models/user.model.js';
import CategoryModel from '../models/category.model.js';

dotenv.config();

async function cleanupDatabase() {
    try {
        console.log('Connecting to MongoDB...');

        // Connect to MongoDB using mongoose
        await mongoose.connect(process.env.MONGO_URI || '', {
            serverSelectionTimeoutMS: 5000,
        });

        console.log('✓ Connected to MongoDB');
        console.log('\nCleaning up test data...\n');

        // Delete all test users
        const userResult = await UserModel.deleteMany({});
        console.log(`✓ Deleted ${userResult.deletedCount} users`);

        // Delete all categories
        const categoryResult = await CategoryModel.deleteMany({});
        console.log(`✓ Deleted ${categoryResult.deletedCount} categories`);

        // Delete all todos
        console.log('\n✓ Database cleanup completed successfully!');
        console.log('\nYou can now run the test with fresh data:');
        console.log('  tsx src/test/category.test.ts\n');

        await mongoose.disconnect();
    } catch (error) {
        console.error('✗ Cleanup failed:', error instanceof Error ? error.message : error);
        process.exit(1);
    }
}

// Run cleanup
cleanupDatabase();
