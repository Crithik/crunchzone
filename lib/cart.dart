import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'providers/cart_provider.dart';
import 'models/cart_item.dart';
import 'models/order.dart';
import 'pages/order_receipt_page.dart';

class CartPage extends ConsumerStatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;
  final bool showAppBar;
  

  const CartPage({Key? key, required this.toggleTheme, required this.themeMode, required this.authService, this.showAppBar = true})
      : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {

  void _updateQuantity(int productId, int quantity) {
    ref.read(cartProvider.notifier).updateQuantity(productId, quantity);
  }
  void _removeItem(int productId) {
    ref.read(cartProvider.notifier).removeFromCart(productId);
  }

  void _proceedToCheckout() {
    final cartItems = ref.read(cartProvider);
    final totalPrice = ref.read(cartTotalProvider);
    
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create order
    final order = Order(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      orderDate: DateTime.now(),
      items: cartItems.map((cartItem) => OrderItem(
        name: cartItem.name,
        price: cartItem.price,
        quantity: cartItem.quantity,
        totalPrice: cartItem.totalPrice,
      )).toList(),
      totalAmount: totalPrice,
    );

    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    // Navigate to receipt page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderReceiptPage(order: order),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CrunchZone",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
      ) : null,
      body: cartItems.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 100, color: isDarkMode ? Colors.white : Colors.black),
                const SizedBox(height: 20),
                Text(
                  "Your cart is empty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Add items from the shop",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: item.image.startsWith('http')
                                      ? NetworkImage(item.image)
                                      : AssetImage(item.image) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs.${item.price}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(236, 170, 27, 1.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity Controls
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _updateQuantity(item.productId, item.quantity - 1),
                                      icon: const Icon(Icons.remove_circle_outline),
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _updateQuantity(item.productId, item.quantity + 1),
                                      icon: const Icon(Icons.add_circle_outline),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => _removeItem(item.productId),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Total and Checkout
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: Rs.${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),                        ),
                        onPressed: _proceedToCheckout,
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
