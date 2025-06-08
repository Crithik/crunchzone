import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../auth_service.dart';
import '../services/admin_api_service.dart';

class FunSnackPage extends StatefulWidget {
  final AuthService authService;

  const FunSnackPage({Key? key, required this.authService}) : super(key: key);

  @override
  _FunSnackPageState createState() => _FunSnackPageState();
}

class _FunSnackPageState extends State<FunSnackPage> with TickerProviderStateMixin {
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late AdminApiService _apiService;
  late AnimationController _shakeAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _cardAnimation;

  List<dynamic> _allProducts = [];
  List<dynamic> _randomProducts = [];
  bool _isLoading = false;
  bool _isShaking = false;
  double _shakeThreshold = 15.0;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService(widget.authService);
    _setupAnimations();
    _loadProducts();
    _startAccelerometerListening();
  }

  void _setupAnimations() {
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeAnimationController, curve: Curves.elasticOut),
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.bounceOut),
    );
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _allProducts = products;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _startAccelerometerListening() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      
      if (acceleration > _shakeThreshold && !_isShaking) {
        DateTime now = DateTime.now();
        if (now.difference(_lastShakeTime).inMilliseconds > 1000) {
          _onShakeDetected();
          _lastShakeTime = now;
        }
      }
    });
  }

  void _onShakeDetected() {
    if (_allProducts.isEmpty || _isLoading) return;

    setState(() {
      _isShaking = true;
      _isLoading = true;
    });

    _shakeAnimationController.forward().then((_) {
      _shakeAnimationController.reverse();
    });

    // Simulate processing time
    Future.delayed(const Duration(milliseconds: 1500), () {
      _generateRandomProducts();
    });
  }

  void _generateRandomProducts() {
    if (_allProducts.length < 3) {
      setState(() {
        _randomProducts = List.from(_allProducts);
        _isLoading = false;
        _isShaking = false;
      });
      _cardAnimationController.forward();
      return;
    }

    final random = Random();
    final shuffled = List.from(_allProducts)..shuffle(random);
    
    setState(() {
      _randomProducts = shuffled.take(3).toList();
      _isLoading = false;
      _isShaking = false;
    });

    _cardAnimationController.reset();
    _cardAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
        title: const Text(
          'Fun Snack Shake!',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: const Icon(
                            Icons.phone_android,
                            size: 60,
                            color: Color.fromRGBO(236, 170, 27, 1.0),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🎲 Shake Your Phone!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Shake your phone to discover 3 random snacks that might become your new favorites!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(236, 170, 27, 1.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Random Products Display
            if (_randomProducts.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '🎉 Your Random Snacks!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimation.value,
                            child: ListView.builder(
                              itemCount: _randomProducts.length,
                              itemBuilder: (context, index) {
                                final product = _randomProducts[index];
                                return _buildProductCard(product, index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_randomProducts.isEmpty && !_isLoading)
              const Expanded(
                child: Center(
                  child: Text(
                    'Shake your phone to get started!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final delay = index * 200;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromRGBO(236, 170, 27, 0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product['image'] != null && product['image'].toString().isNotEmpty
                              ? Image.network(
                                  product['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.fastfood, size: 40);
                                  },
                                )
                              : const Icon(Icons.fastfood, size: 40),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['description'] ?? 'Delicious snack!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${product['price'] ?? '0'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(236, 170, 27, 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Lucky number badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(236, 170, 27, 1.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _shakeAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
}