import { Router } from 'express';
import { ToDoController } from '../controller/todo.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const ToDoRouter = Router();

ToDoRouter.post("/createToDo", authenticateToken, ToDoController.createToDo);
ToDoRouter.get('/getUserTodoList', authenticateToken, ToDoController.getUserToDos);
ToDoRouter.post("/deleteTodo", authenticateToken, ToDoController.deleteToDo);
ToDoRouter.post("/updateTodo", authenticateToken, ToDoController.updateToDo);

export default ToDoRouter;
