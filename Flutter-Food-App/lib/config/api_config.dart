/// API Configuration
/// This file should be updated with your actual backend URL

class ApiConfig {
  /// Backend API Base URL
  /// Change this to your backend server URL
  static const String baseUrl = 'http://localhost:3000';
  
  /// Timeout duration for API requests (in seconds)
  static const int requestTimeout = 30;
  
  /// Enable debug logging
  static const bool enableDebugLogging = true;
  
  /// VNPAY Configuration (if using sandbox)
  static const String vnpayTmnCode = 'G2P4PHXX';
  static const String vnpayEnvironment = 'sandbox'; // 'production' or 'sandbox'
}

/// API Endpoints
class ApiEndpoints {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Auth
  static const String register = '$baseUrl/users/createUser';
  static const String login = '$baseUrl/users/login';
  static const String forgotPassword = '$baseUrl/users/forgot-password';
  static const String resetPassword = '$baseUrl/users/reset-password';
  static const String sendOtp = '$baseUrl/users/send-otp';
  static const String verifyOtp = '$baseUrl/users/verify-otp';
  static const String resendOtp = '$baseUrl/users/resend-otp';
  
  // Categories
  static const String getCategories = '$baseUrl/categories/getCategory';
  
  // Foods
  static const String foods = '$baseUrl/foods';
  static String foodsByCategory(String categoryId) => '$baseUrl/categories/getFood/$categoryId';
  static String foodById(String foodId) => '$baseUrl/foods/$foodId';
  static const String searchFoods = '$baseUrl/foods/search';
  
  // Orders
  static const String createOrder = '$baseUrl/users/addOrder';
  static String getOrder(String orderId) => '$baseUrl/orders/$orderId';
  static const String userOrders = '$baseUrl/orders/user/orders';
  static String updateOrderStatus(String orderId) => '$baseUrl/orders/$orderId/status';
  static String cancelOrder(String orderId) => '$baseUrl/orders/$orderId/cancel';
  
  // Payments
  static const String createPayment = '$baseUrl/payments/create-payment';
  static String checkPaymentStatus(String orderId) => '$baseUrl/payments/check-status/$orderId';
  static const String userPayments = '$baseUrl/payments/user-payments';
  static const String vnpayReturn = '$baseUrl/payments/vnpay-return';
  static const String vnpayIpn = '$baseUrl/payments/vnpay-ipn';
  
  // Todo Endpoints (if needed)
  static const String createTodo = '$baseUrl/todos/createToDo';
  static const String getUserTodos = '$baseUrl/todos/getUserTodoList';
  static String deleteTodo(String todoId) => '$baseUrl/todos/deleteTodo/$todoId';
  static String updateTodo(String todoId) => '$baseUrl/todos/updateTodo/$todoId';
}
