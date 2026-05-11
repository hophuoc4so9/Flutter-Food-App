import { Router } from 'express';
import { ToDoController } from '../controller/todo.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const ToDoRouter = Router();

/**
 * @swagger
 * /todos/createToDo:
 *   post:
 *     tags:
 *       - Todo Management
 *     summary: Create a new todo
 *     description: Create a new todo item for the authenticated user
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *             properties:
 *               title:
 *                 type: string
 *                 example: "Buy groceries"
 *               description:
 *                 type: string
 *                 example: "Buy milk, bread, and eggs"
 *     responses:
 *       200:
 *         description: Todo created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 success:
 *                   $ref: '#/components/schemas/Todo'
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
ToDoRouter.post("/createToDo", authenticateToken, ToDoController.createToDo);

/**
 * @swagger
 * /todos/getUserTodoList:
 *   get:
 *     tags:
 *       - Todo Management
 *     summary: Get user's todo list
 *     description: Retrieve all todos for the authenticated user
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Todo list retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 success:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Todo'
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
ToDoRouter.get('/getUserTodoList', authenticateToken, ToDoController.getUserToDos);

/**
 * @swagger
 * /todos/deleteTodo:
 *   post:
 *     tags:
 *       - Todo Management
 *     summary: Delete a todo
 *     description: Delete a todo item by ID
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id
 *             properties:
 *               id:
 *                 type: string
 *                 description: Todo ID to delete
 *                 example: "507f1f77bcf86cd799439011"
 *     responses:
 *       200:
 *         description: Todo deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Todo deleted successfully"
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Todo not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
ToDoRouter.post("/deleteTodo", authenticateToken, ToDoController.deleteToDo);

/**
 * @swagger
 * /todos/updateTodo:
 *   post:
 *     tags:
 *       - Todo Management
 *     summary: Update a todo
 *     description: Update a todo item's details
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - id
 *             properties:
 *               id:
 *                 type: string
 *                 description: Todo ID to update
 *                 example: "507f1f77bcf86cd799439011"
 *               title:
 *                 type: string
 *                 example: "Buy groceries"
 *               description:
 *                 type: string
 *                 example: "Buy milk, bread, and eggs"
 *               isCompleted:
 *                 type: boolean
 *                 example: false
 *     responses:
 *       200:
 *         description: Todo updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 success:
 *                   $ref: '#/components/schemas/Todo'
 *       401:
 *         description: Unauthorized - Missing or invalid token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Todo not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
ToDoRouter.post("/updateTodo", authenticateToken, ToDoController.updateToDo);

export default ToDoRouter;
