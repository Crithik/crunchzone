import 'package:flutter/material.dart';
import 'details.dart';
import 'services/product_service.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'auth_service.dart';

class ProductPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService? authService;
  final bool showAppBar;

  const ProductPage({Key? key, required this.toggleTheme, required this.themeMode, this.authService, this.showAppBar = true}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Future<List<Product>> futureProducts = Future.value([]);
  Future<List<Category>> futureCategories = Future.value([]);
  int? selectedCategoryId;
  List<Product> allProducts = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
    Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      print('Starting to load categories and products...');
      
      // Load categories and products in parallel with timeout
      final categoriesFuture = ProductService.fetchCategories().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print('Categories request timed out');
          return <Category>[];
        },
      );
      
      final productsFuture = ProductService.fetchProducts().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print('Products request timed out');
          return <Product>[];
        },
      );
      
      final results = await Future.wait([categoriesFuture, productsFuture]);
      
      if (!mounted) return;
      
      final categories = results[0] as List<Category>;
      final products = results[1] as List<Product>;
      
      print('Loaded ${categories.length} categories and ${products.length} products');
      
      setState(() {
        futureCategories = Future.value(categories);
        allProducts = products;
        futureProducts = Future.value(
          filterProductsByCategory(allProducts, selectedCategoryId)
        );
        isLoading = false;
      });
      
    } catch (e) {
      print('Error loading data: $e');
      if (!mounted) return;
      
      setState(() {
        futureCategories = Future.value(<Category>[]);
        futureProducts = Future.value(<Product>[]);
        isLoading = false;
      });
      
      // Show user-friendly error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load products. Please check your connection and try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }
  
  List<Product> filterProductsByCategory(List<Product> products, int? categoryId) {
    if (categoryId == null) {
      return products;
    }
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
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
      ) : null,
      
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 600; 
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,                  children: [
                    // Debug information (remove this in production)
                    if (allProducts.isEmpty && !isLoading)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'API Base URL: http://13.201.189.84/api',
                              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                            ),
                            Text(
                              'Products endpoint: /products',
                              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                            ),
                            Text(
                              'Categories endpoint: /categories',
                              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Check the debug console for API response details.',
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.orange[600]),
                            ),
                          ],
                        ),
                      ),
                    
                    Text(
                      "Build your box",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Solve your craving in one place, customize for the preference you want",
                      style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                    const SizedBox(height: 15),

                    // Categories
                    FutureBuilder<List<Category>>(
                      future: futureCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 50,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          print('Categories error: ${snapshot.error}');
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.start,
                            children: [
                              _filterButton("All", isDarkMode),
                            ],
                          );
                        } else {
                          final categories = snapshot.data ?? [];
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.start,
                            children: [
                              _filterButton("All", isDarkMode),
                              ...categories.map((category) => 
                                _filterButton(category.name, isDarkMode, categoryId: category.id)
                              ).toList(),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Products
                    isLoading 
                      ? Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Loading products...',
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        )
                      : FutureBuilder<List<Product>>(
                          future: futureProducts,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              String errorMessage = 'Unable to load products';
                              print('Products error: ${snapshot.error}');
                              
                              return Container(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        errorMessage,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _loadData,
                                        child: Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              final products = snapshot.data ?? [];
                              if (products.isEmpty) {
                                return Container(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                                        SizedBox(height: 16),
                                        Text(
                                          selectedCategoryId == null
                                              ? 'No products available'
                                              : 'No products in this category',
                                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isWideScreen ? 3 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: isWideScreen ? 0.85 : 0.6, 
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return _buildProductCard(
                                    product.image,
                                    product.name,
                                    product.price,
                                    isDarkMode,
                                  );
                                },
                              );
                            }
                          },
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterButton(String text, bool isDarkMode, {int? categoryId}) {
    bool isSelected = (categoryId == null && selectedCategoryId == null) || 
                       (categoryId != null && categoryId == selectedCategoryId);
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? const Color.fromRGBO(236, 170, 27, 1.0)
            : isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isSelected
            ? Colors.black
            : isDarkMode ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      onPressed: () {
        if (!mounted) return;
        
        setState(() {
          if (selectedCategoryId == categoryId) {
            selectedCategoryId = null;
          } else {
            selectedCategoryId = categoryId;
          }
          
          futureProducts = Future.value(filterProductsByCategory(allProducts, selectedCategoryId));
        });
      },
      child: Text(text),
    );
  }

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
              child: imagePath.startsWith('http') 
                ? Image.network(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 80, color: Colors.black54);
                    },
                  )
                : Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 80, color: Colors.black54);
                    },
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
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
              child: const Text("View details"),
            ),
          ],
        ),
      ),
    );
  }
}
