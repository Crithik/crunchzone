import 'package:flutter/material.dart';
import 'details.dart';
import 'cart.dart';
import 'login.dart';

class ProductPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  ProductPage({required this.toggleTheme, required this.themeMode});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentIndex = 1; 

  void _onTabChange(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(
            toggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
      );
    } else if (index == 3) { 
      Navigator.push(
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    List<Map<String, String>> products = [
      {"image": "assets/image/6281036008671.png", "name": "Doritos Nacho Cheese", "price": "RS.1,600"},
      {"image": "assets/image/6291003017667.png", "name": "Cheetos Crunchy Cheese", "price": "RS.2,250"},
      {"image": "assets/image/60410066317.png", "name": "Lays Stax Bar-B-Q", "price": "RS.1,700"},
      {"image": "assets/image/5012454063680.png", "name": "Lindt Lindor Advent Calendar", "price": "RS.7,500"},
    ];

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
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.black,
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Build your box",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Solve your craving in one place, customize for the preference you want",
                    style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  SizedBox(height: 15),

                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: [
                      _filterButton("Sweet & Sour", isDarkMode),
                      _filterButton("Sugar Free", isDarkMode),
                      _filterButton("Popular", isDarkMode),
                      _filterButton("Vegan", isDarkMode),
                    ],
                  ),
                  SizedBox(height: 20),

                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWideScreen ? 0.85 : 0.6, 
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        products[index]["image"]!,
                        products[index]["name"]!,
                        products[index]["price"]!,
                        isDarkMode,
                      );
                    },
                  ),
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

  //  Filter Button Widget
  Widget _filterButton(String text, bool isDarkMode) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      onPressed: () {},
      child: Text(text),
    );
  }

  // Product Card Widget
  Widget _buildProductCard(String imagePath, String name, String price, bool isDarkMode) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                width: double.infinity, 
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 80, color: Colors.black54);
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(
                      image: imagePath,
                      name: name,
                      price: price,
                    ),
                  ),
                );
              },
              child: Text("View details"),
            ),
          ],
        ),
      ),
    );
  }
}
