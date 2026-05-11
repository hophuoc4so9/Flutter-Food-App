import CategoryService from '../services/category.service.js';

export class CategoryController {
    static async addCategory(req: any, res: any, next: any): Promise<any> {
        try {
            const { name, image_url, food } = req.body;
            const newCategory = await CategoryService.addCategory(name, image_url, food);
            res.json({ status: true, success: newCategory });
        } catch (err) {
            next(err);
        }
    }

    static async addFood(req: any, res: any, next: any): Promise<any> {
        try {
            const { categoryId, name, image_url, price } = req.body;
            const updatedCategory = await CategoryService.addFood(categoryId, name, image_url, price);
            res.json({ status: true, success: updatedCategory });
        } catch (err) {
            next(err);
        }
    }

    static async getCategory(req: any, res: any, next: any): Promise<any> {
        try {
            const categories = await CategoryService.getCategory();
            res.json({ status: true, success: categories });
        } catch (err) {
            next(err);
        }
    }

    static async getFood(req: any, res: any, next: any): Promise<any> {
        try {
            const { id } = req.params;
            const foods = await CategoryService.getFood(id);
            res.json({ status: true, success: foods });
        } catch (err) {
            next(err);
        }
    }
}
