import { Router } from 'express';
import { UserController } from '../controller/user.controller.js';

const UserRouter = Router();

UserRouter.post("/createUser", UserController.createUser);
UserRouter.post("/login", UserController.loginUser);

export default UserRouter;
