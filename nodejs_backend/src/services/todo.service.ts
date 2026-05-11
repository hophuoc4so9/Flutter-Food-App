import ToDoModel from '../models/todo.model.js';

class ToDoService {
    static async createToDo(userId: string, title: string, description: string): Promise<any> {
        const createToDo = new ToDoModel({
            userId,
            title,
            description
        });
        return await createToDo.save();
    }

    static async getUserToDos(userId: string): Promise<any> {
        return await ToDoModel.find({ userId });
    }

    static async updateToDo(toDoId: string, title: string, description: string): Promise<any> {
        return await ToDoModel.findByIdAndUpdate(toDoId, { title, description }, { new: true });
    }

    static async deleteToDo(toDoId: string): Promise<any> {
        return await ToDoModel.findByIdAndDelete(toDoId);
    }
}

export default ToDoService;
