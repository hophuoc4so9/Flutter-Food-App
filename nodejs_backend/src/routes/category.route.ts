import { Router } from 'express';
import { CategoryController } from '../controller/category.controller.js';

const CategoryRouter = Router();

CategoryRouter.post("/addCategory", CategoryController.addCategory);
CategoryRouter.post("/addFood", CategoryController.addFood);
CategoryRouter.get("/getCategory", CategoryController.getCategory);
CategoryRouter.get("/getFood/:id", CategoryController.getFood);

export default CategoryRouter;
