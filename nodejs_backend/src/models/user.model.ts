import connectDB from '../config/db.js';
import { Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

const foodInOrderSchema = new Schema({
    food_id: {
        type: String,
        required: true,
    },
    quantity: {
        type: Number,
        required: true,
    },
}, { _id: false });

const orderSchema = new Schema({
    food: {
        type: [foodInOrderSchema],
        required: true,
    },
    total: {
        type: Number,
        required: true,
    },
}, { _id: false });

const userSchema = new Schema({
    email: {
        type: String,
        lowercase: true,
        required: [true, "userName can't be empty"],
        match: [
            /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/,
            "userName format is not correct",
        ],
        unique: true,
    },

    password: {
        type: String,
        required: [true, "password is required"],
    },

    otpCode: {
        type: String,
        default: null,
    },

    otpExpire: {
        type: Date,
        default: null,
    },

    isEmailVerified: {
        type: Boolean,
        default: false,
    },

    isPasswordResetVerified: {
        type: Boolean,
        default: false,
    },

    orders: {
        type: [orderSchema],
        default: [],
    },
}, { timestamps: true });

userSchema.pre('save', async function (this: any) {
    const user = this;

    if (!user.isModified('password')) return;

    const salt = await bcrypt.genSalt(10);

    user.password = await bcrypt.hash(user.password, salt);
});

userSchema.methods.comparePassword = async function (
    this: any,
    candidatePassword: string
): Promise<boolean> {

    return bcrypt.compare(candidatePassword, this.password);
};

const connection = connectDB();

const UserModel = connection.model('User', userSchema);

export default UserModel;