import UserService from '../services/user.service.js';

export class UserController {
    static async createUser(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, password } = req.body;
            const duplicate = await UserService.checkUser(email);
            if (duplicate) {
                return res.json({ status: false, message: "Email already exists" });
            }
            const newUser = await UserService.registerUser(email, password);
            res.json({ status: true, success: newUser });
        } catch (err) {
            next(err);
        }
    }

    static async loginUser(req: any, res: any, next: any): Promise<any> {
        try {
            const { email, password } = req.body;
            const user = await UserService.getUserByEmail(email);
            if (!user) {
                return res.json({ status: false, message: "User not found" });
            }
            const isMatch = await user.comparePassword(password);
            if (!isMatch) {
                return res.json({ status: false, message: "User or password is incorrect" });
            }
            const tokenData = { _id: user._id, email: user.email };
            const token = await UserService.generateAccessToken(tokenData, process.env.JWT_SECRET || 'secret', '72h');
            res.status(200).json({ status: true, success: { token } });
        } catch (err) {
            next(err);
        }
    }
}
