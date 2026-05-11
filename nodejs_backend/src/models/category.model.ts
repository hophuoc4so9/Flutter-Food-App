import connectDB from '../config/db.js';
import { Schema } from 'mongoose';

const foodSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    image_url: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
}, { _id: false });

const categorySchema = new Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    image_url: {
        type: String,
        required: true,
    },
    food: {
        type: [foodSchema],
        default: [],
    },
}, { timestamps: true });

const connection = connectDB();
const CategoryModel = connection.model('Category', categorySchema);

export default CategoryModel;
