import mongoose, { Schema } from 'mongoose';

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

const CategoryModel = mongoose.model('Category', categorySchema);

export default CategoryModel;
