import app from './app.js';
import userRouter from './routes/user.route.js';
import todoRouter from './routes/todo.route.js';

const port = Number(process.env.PORT || 3000);

app.use('/users', userRouter);
app.use('/todos', todoRouter);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
