import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'products.dart';
import 'cart.dart';
import 'auth_service.dart';
import 'account_page.dart';
import 'providers/cart_provider.dart';
import 'services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class HomePage extends ConsumerStatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;

  HomePage({required this.toggleTheme, required this.themeMode, required this.authService});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _showConnectedBanner = false;
  
  // Gyroscope variables
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;
  
  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
    _startGyroscopeListening();
  }

  void _startGyroscopeListening() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await _connectivityService.checkConnection();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  void _listenToConnectivityChanges() {
    _connectivityService.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        final wasConnected = _isConnected;
        final isNowConnected = !results.contains(ConnectivityResult.none);
        
        setState(() {
          _isConnected = isNowConnected;
          
          // Show connected banner only when reconnecting (was disconnected, now connected)
          if (!wasConnected && isNowConnected) {
            _showConnectedBanner = true;
            
            // Hide the banner after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showConnectedBanner = false;
                });
              }
            });
          }
        });      }
    });
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 1:
        return ProductPage(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
          authService: widget.authService,
          showAppBar: false,
        );      case 2:
        return CartPage(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
          authService: widget.authService,
          showAppBar: false,
        );
      case 3:
        return AccountPage(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
          authService: widget.authService,
          showAppBar: false,
        );
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: screenWidth,
                height: 280,  
                decoration:  BoxDecoration(
                  color: const Color.fromRGBO(236, 170, 27, 1.0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(180),
                    bottomRight: Radius.circular(180),
                  ),
                ),
              ),
              
              Positioned(
                bottom: -10,
                child: Image.asset(
                  'assets/image/s-zoom-modified.png',
                  width: 300,
                  height: 250,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          Text(
            "Snack time. Delivered.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Healthy and delicious snacks sent right to you.",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.yellow : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {},
            child: Text("START SNACKING", style: TextStyle(fontSize: 16)),
          ),

          SizedBox(height: 40),

          // "How It Works" Section in Column
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  "How It Works",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),                
                //  1st box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.identity()
                    ..translate(_gyroZ * 20, _gyroX * 10)
                    ..rotateZ(_gyroY * 0.1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/image/Perky_Pumpkin_Seeds.png', 
                        width: 80,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "1. Choose your snacks",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Customize your own\nsnack box",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 2nd box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.identity()
                    ..translate(_gyroZ * 20, _gyroX * 10)
                    ..rotateZ(_gyroY * 0.1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/image/Relaxing_Cashew.png', 
                        width: 80,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "2. Get your delivery",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "We deliver straight to\nyour doorstep",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 3rd box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.identity()
                    ..translate(_gyroZ * 20, _gyroX * 10)
                    ..rotateZ(_gyroY * 0.1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/image/Hiking_Almond.png', 
                        width: 80,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "3. Get Snacking",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Perfect for busy workdays,\nor lazy Sundays.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 218, 155, 20),
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
      body: Column(
        children: [
          // Connectivity Banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "No internet connection. Some features may not work properly.",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    onPressed: _checkInitialConnectivity,
                    tooltip: 'Retry connection',
                  ),
                ],
              ),
            ),          // Connected Banner (shows briefly when reconnected)
          if (_showConnectedBanner)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Connected to internet",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),          // Main Content
          Expanded(
            child: _getCurrentPage(),
          ),
        ],
      ),bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
        selectedItemColor: isDarkMode ? Colors.yellow : Colors.black,
        unselectedItemColor: isDarkMode ? Colors.grey : Colors.black54,
        backgroundColor: isDarkMode ? Colors.black : Colors.yellow,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Consumer(
              builder: (context, ref, child) {
                final itemCount = ref.watch(cartItemCountProvider);
                return Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],      ),
    );
  }

  @override
  void dispose() {
    _gyroscopeSubscription.cancel();
    super.dispose();
  }
}
