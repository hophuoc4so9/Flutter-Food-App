import app from './app.js';
import userRouter from './routes/user.route.js';
import categoryRouter from './routes/category.route.js';
import paymentRouter from './routes/payment.route.js';

const port = Number(process.env.PORT || 3000);

app.use('/users', userRouter);
app.use('/payments', paymentRouter);
app.use('/categories', categoryRouter);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
