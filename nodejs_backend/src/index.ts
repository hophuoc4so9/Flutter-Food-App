import app from './app.js';
import connectDB from './config/db.js';
import userRouter from './routes/user.route.js';
import categoryRouter from './routes/category.route.js';
import paymentRouter from './routes/payment.route.js';

const port = Number(process.env.PORT || 3000);

app.use('/users', userRouter);
app.use('/payments', paymentRouter);
app.use('/categories', categoryRouter);

const startServer = async () => {
  try {
    // Connect to MongoDB first
    await connectDB();
    
    // Start server only after DB is connected
    app.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
