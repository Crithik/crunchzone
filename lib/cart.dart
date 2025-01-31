import 'package:flutter/material.dart';
import 'products.dart';
import 'main.dart';
import 'login.dart';

class CartPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  CartPage({required this.toggleTheme, required this.themeMode});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _currentIndex = 2;

  // Cart items with quantity and price
  List<Map<String, dynamic>> cartItems = [
    {
      "image": "assets/image/6281036008671.png",
      "name": "Doritos Nacho Cheese - 210G",
      "price": 1600,
      "quantity": 1
    },
    {
      "image": "assets/image/60410066317.png",
      "name": "Smak Spicy Chick Peas - 80g",
      "price": 540,
      "quantity": 3
    },
  ];

  void _onTabChange(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            toggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPage(
            toggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            toggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Calculate total price
  int _calculateTotalPrice() {
  int total = 0;
  for (var item in cartItems) {
    total += (item["price"] as int) * (item["quantity"] as int);
  }
  return total;
}

  void _increaseQuantity(int index) {
    setState(() {
      cartItems[index]["quantity"]++;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]["quantity"] > 1) {
        cartItems[index]["quantity"]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
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
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 100 : 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: List.generate(
                        cartItems.length,
                        (index) => _buildCartItem(
                          index,
                          cartItems[index]["image"],
                          cartItems[index]["name"],
                          cartItems[index]["price"],
                          cartItems[index]["quantity"],
                          isDarkMode,
                        ),
                      ),
                    ),
                  ),

                  Divider(thickness: 2, color: isDarkMode ? Colors.white : Colors.black),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "RS.${_calculateTotalPrice()}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.yellow : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {},
                    child: Text("Checkout", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
        selectedItemColor: isDarkMode ? Colors.yellow : Colors.black,
        unselectedItemColor: isDarkMode ? Colors.grey : Colors.black54,
        backgroundColor: isDarkMode ? Colors.black : Colors.yellow,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, String imagePath, String name, int price, int quantity, bool isDarkMode) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Card(
        color: isDarkMode ? Colors.black54 : Colors.white,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 80, color: Colors.grey);
                },
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "RS.${price * quantity}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.yellow : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () => _decreaseQuantity(index),
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () => _increaseQuantity(index),
                  ),
                ],
              ),
              Icon(Icons.close, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
