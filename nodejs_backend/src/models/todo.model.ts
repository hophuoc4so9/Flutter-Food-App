import connectDB from '../config/db.js';
import { Schema } from 'mongoose';
import UserModel from './user.model.js';

const toDoSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: UserModel.modelName
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
}, { timestamps: true });

const connection = connectDB();
const ToDoModel = connection.model('todo', toDoSchema);
export default ToDoModel;
