// Configuration Examples for Shopping Cart & Payment Integration
// Copy and adapt these to your application

import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/cart_service.dart';
import 'lib/services/order_service.dart';
import 'lib/services/payment_service.dart';
import 'lib/screens/cart_page.dart';
import 'lib/screens/payment_result_page.dart';

/// ============================================================================
/// CONFIGURATION TEMPLATE - Update these values for your setup
/// ============================================================================

// 1. MAIN.DART - Initialization Example
// (Already implemented, just showing for reference)
void mainConfigExample() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Cart persistence is automatic via SharedPreferences
  runApp(MyApp());
}

// 2. DASHBOARD - Cart Navigation Example
void cartNavigationExample(BuildContext context, String token) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CartPage(
        token: token,
        baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
      ),
    ),
  );
}

// 3. SERVICE INITIALIZATION EXAMPLES

/// Initialize CartService
Future<CartService> initializeCartService() async {
  final prefs = await SharedPreferences.getInstance();
  return CartService(prefs: prefs);
}

/// Initialize OrderService
OrderService initializeOrderService(String token) {
  return OrderService(
    baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
    authToken: token,
  );
}

/// Initialize PaymentService
PaymentService initializePaymentService(String token) {
  return PaymentService(
    baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
    authToken: token,
  );
}

// 4. USAGE EXAMPLES IN YOUR SCREENS

/// Example: In a custom screen using the services
class ExampleUsageScreen extends StatefulWidget {
  final String token;
  const ExampleUsageScreen({required this.token});

  @override
  State<ExampleUsageScreen> createState() => _ExampleUsageScreenState();
}

class _ExampleUsageScreenState extends State<ExampleUsageScreen> {
  late CartService _cartService;
  late OrderService _orderService;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _cartService = CartService(prefs: prefs);
    _orderService = OrderService(
      baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
      authToken: widget.token,
    );
    _paymentService = PaymentService(
      baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
      authToken: widget.token,
    );
  }

  // Example: Get cart items
  void loadCartItems() async {
    final items = await _cartService.getCartItems();
    print('Cart items: ${items.length}');
    
    final total = await _cartService.getTotalPrice();
    print('Total price: \$$total');
  }

  // Example: Add item to cart
  void addItemExample() async {
    final cartItem = CartItem(
      id: 'food_123',
      name: 'Pizza',
      imageUrl: 'https://...',
      price: 12.99,
      quantity: 1,
    );
    
    await _cartService.addToCart(cartItem);
  }

  // Example: Create order and process payment
  void checkoutExample() async {
    try {
      // Get cart items
      final cartItems = await _cartService.getCartItems();
      
      if (cartItems.isEmpty) {
        print('Cart is empty');
        return;
      }

      // Step 1: Create order
      final orderResult = await _orderService.createOrder(
        items: cartItems,
        description: 'Food Order - ${cartItems.length} items',
      );

      if (!orderResult['status']) {
        print('Order creation failed: ${orderResult['message']}');
        return;
      }

      final orderId = orderResult['orderId'];
      print('Order created: $orderId');

      // Step 2: Create payment
      final totalAmount = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final paymentResult = await _paymentService.createPayment(
        amount: totalAmount,
        description: 'Order #$orderId',
      );

      if (!paymentResult['status']) {
        print('Payment creation failed: ${paymentResult['message']}');
        return;
      }

      // Step 3: Launch payment URL
      final paymentUrl = paymentResult['paymentUrl'];
      print('Payment URL: $paymentUrl');
      // Use url_launcher to open: launchUrl(Uri.parse(paymentUrl))

      // Step 4: Clear cart
      await _cartService.clearCart();
      print('Cart cleared');

    } catch (e) {
      print('Error during checkout: $e');
    }
  }

  // Example: Check payment status
  void checkPaymentStatusExample() async {
    final result = await _paymentService.checkPaymentStatus('order_123');
    
    if (result['status']) {
      final payment = result['payment'];
      print('Payment status: ${payment['status']}');
      print('Amount: ${payment['amount']}');
    }
  }

  // Example: Navigate to payment result
  void goToPaymentResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          token: widget.token,
          baseUrl: 'http://localhost:3000', // ⚠️ UPDATE THIS
          orderId: 'order_123',
          status: 'SUCCESS',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: checkoutExample,
          child: const Text('Checkout Example'),
        ),
      ),
    );
  }
}

// 5. ENVIRONMENT-SPECIFIC CONFIGURATION

/// Development Configuration
class DevConfig {
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String appName = 'Food App (DEV)';
  static const bool enableDebugLogging = true;
}

/// Production Configuration
class ProdConfig {
  static const String apiBaseUrl = 'https://api.yourdomain.com';
  static const String appName = 'Food App';
  static const bool enableDebugLogging = false;
}

/// Get current configuration based on environment
String getApiBaseUrl({bool isProduction = false}) {
  return isProduction ? ProdConfig.apiBaseUrl : DevConfig.apiBaseUrl;
}

// 6. BACKEND REQUIREMENTS CHECKLIST

/*
Ensure your backend has these endpoints:

✅ Order Creation
   POST /orders/create
   Body: { items: [...], totalAmount: 50.00, description: "..." }
   Response: { status: true, success: { orderId: "...", ... } }

✅ Payment Creation (VNPAY)
   POST /payments/create-payment
   Body: { amount: 50.00, description: "Order #123" }
   Response: { 
     status: true, 
     success: { 
       orderId: "...", 
       paymentUrl: "https://sandbox.vnpayment.vn/...",
       amount: 50.00 
     } 
   }

✅ Payment Status Check
   GET /payments/check-status/{orderId}
   Response: { status: true, success: { orderId, amount, status, ... } }

✅ VNPAY Callbacks
   GET /payments/vnpay-return (User redirect)
   GET /payments/vnpay-ipn (Server callback)

✅ Authentication
   All endpoints should validate Bearer token in Authorization header
   Authorization: Bearer {token}
*/

// 7. SHARED PREFERENCES KEYS

/*
Cart storage key:
  Key: "shopping_cart"
  Format: JSON array of CartItem objects

Example data structure:
[
  {
    "id": "food_1",
    "name": "Pizza Margherita",
    "imageUrl": "https://...",
    "price": 12.99,
    "description": "Classic pizza",
    "quantity": 2
  },
  {
    "id": "food_2",
    "name": "Pasta",
    "imageUrl": "https://...",
    "price": 8.99,
    "description": "Delicious pasta",
    "quantity": 1
  }
]
*/

// 8. ERROR HANDLING PATTERNS

Future<void> handleCheckoutError(dynamic error, BuildContext context) {
  if (error.toString().contains('Socket')) {
    // Network error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error. Please check your connection.')),
    );
  } else if (error.toString().contains('401')) {
    // Authentication error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authentication failed. Please login again.')),
    );
  } else {
    // General error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
  return Future.value();
}

// 9. TESTING CHECKLIST

/*
Before deploying to production:

□ Cart persistence works (items remain after app restart)
□ Add to cart - updates quantity if item exists
□ Remove from cart - item removed from list
□ Clear cart - all items removed
□ Cart count badge - shows correct number
□ Checkout flow - order created and payment initiated
□ Payment URL - opens in browser/VNPAY
□ Payment result - displays correct status
□ Cart cleared - after successful payment initiation
□ Error handling - shows appropriate messages
□ Network errors - handled gracefully
□ Authentication - token validation works
□ VNPAY sandbox - test payment works
*/
