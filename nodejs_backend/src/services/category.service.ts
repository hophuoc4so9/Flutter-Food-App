import CategoryModel from '../models/category.model.js';

class CategoryService {
    static async addCategory(name: string, image_url: string, food: Array<{ name: string; image_url: string; price: number }>): Promise<any> {
        try {
            const createCategory = new CategoryModel({
                name,
                image_url,
                food,
            });
            return await createCategory.save();
        } catch (error) {
            throw error;
        }
    }

    static async addFood(categoryId: string, name: string, image_url: string, price: number): Promise<any> {
        try {
            const category = await CategoryModel.findById(categoryId);
            if (!category) {
                throw new Error('Category not found');
            }
            const newFood = { name, image_url, price };
            category.food.push(newFood);
            return await category.save();
        } catch (error) {
            throw error;
        }
    }

    static async getCategory(): Promise<any> {
        try {
            return await CategoryModel.find();
        } catch (error) {
            throw error;
        }
    }

    static async getFood(id: string): Promise<any> {
        try {
            const category = await CategoryModel.findById(id);
            return category ? category.food : [];
        } catch (error) {
            throw error;
        }
    }
}

export default CategoryService;
