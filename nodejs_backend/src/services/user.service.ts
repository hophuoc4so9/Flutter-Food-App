import UserModel from '../models/user.model.js';
import jwt from 'jsonwebtoken';

class UserService {
    static async registerUser(email: string, password: string): Promise<any> {
        try {
            const createUser = new UserModel({
                email,
                password
            });
            const savedUser = await createUser.save();
            return savedUser;
        } catch (error) {
            throw error;
        }
    }

    static async getUserByEmail(email: string): Promise<any> {
        try {
            const user = await UserModel.findOne({ email });
            return user;
        } catch (error) {
            throw error;
        }
    }

    static async checkUser(email: string): Promise<any> {
        try {
            return await UserModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    static async generateAccessToken(tokenData: any, JWTSecret: string, expiresIn: string): Promise<string> {
        return jwt.sign(tokenData, JWTSecret, { expiresIn: expiresIn as any });
    }
}

export default UserService;
