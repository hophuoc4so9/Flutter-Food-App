import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

const connectDB = async (): Promise<void> => {
    try {
        const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/food_app';
        
        await mongoose.connect(mongoUri, {
            serverSelectionTimeoutMS: 5000,
            socketTimeoutMS: 45000,
            retryWrites: true,
            w: 'majority'
        });
        
        console.log('✓ Connected to MongoDB');
    } catch (error) {
        console.error('✗ Error connecting to MongoDB:', error instanceof Error ? error.message : error);
        process.exit(1);
    }
};

export default connectDB;
