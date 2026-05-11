import ToDoService from "../services/todo.service.js";

export class ToDoController {
    static async createToDo(req: any, res: any, next: any): Promise<void> {
        try {
            const userId = req.user?._id || req.body.userId;
            const { title, description } = req.body;

            if (!userId) {
                res.status(400).json({ status: false, message: "User ID is required" });
                return;
            }

            const newToDo = await ToDoService.createToDo(userId, title, description);
            res.json({ status: true, success: newToDo });
        } catch (err) {
            next(err);
        }
    }

    static async getUserToDos(req: any, res: any, next: any): Promise<void> {
        try {
            const userId = req.user?._id || req.body.userId || req.query.userId;

            if (!userId) {
                res.status(400).json({ status: false, message: "User ID is required" });
                return;
            }

            let todoData = await ToDoService.getUserToDos(userId);
            res.json({ status: true, success: todoData });
        } catch (err) {
            next(err);
        }
    }

    static async updateToDo(req: any, res: any, next: any): Promise<void> {
        try {
            const { toDoId, title, description } = req.body;
            const updatedToDo = await ToDoService.updateToDo(toDoId, title, description);
            res.json({ status: true, success: updatedToDo });
        } catch (err) {
            next(err);
        }
    }

    static async deleteToDo(req: any, res: any, next: any): Promise<void> {
        try {
            const { toDoId } = req.body;
            const deletedToDo = await ToDoService.deleteToDo(toDoId);
            res.json({ status: true, success: deletedToDo });
        } catch (err) {
            next(err);
        }
    }
}
