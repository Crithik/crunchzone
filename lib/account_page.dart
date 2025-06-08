// filepath: c:\Flutter Projects\crunchzone\lib\account_page.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'pages/fun_snack_page.dart';
import 'package:battery_plus/battery_plus.dart';

class AccountPage extends StatefulWidget {  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;
  final bool showAppBar;  const AccountPage({
    Key? key, 
    required this.toggleTheme, 
    required this.themeMode, 
    required this.authService,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = false;
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  @override
  void initState() {
    super.initState();
    _getBatteryInfo();
    _listenToBatteryChanges();
  }

  Future<void> _getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      
      if (mounted) {
        setState(() {
          _batteryLevel = batteryLevel;
          _batteryState = batteryState;
        });
      }
    } catch (e) {
      print('Error getting battery info: $e');
    }
  }

  void _listenToBatteryChanges() {
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (mounted) {
        setState(() {
          _batteryState = state;
        });
      }
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.logout();
      // The AuthWrapper will automatically navigate to the login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e'))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }  }

  IconData _getBatteryIcon() {
    switch (_batteryState) {
      case BatteryState.charging:
        return Icons.battery_charging_full;
      case BatteryState.full:
        return Icons.battery_full;
      case BatteryState.discharging:
        if (_batteryLevel <= 20) {
          return Icons.battery_alert;
        } else if (_batteryLevel <= 50) {
          return Icons.battery_3_bar;
        } else {
          return Icons.battery_full;
        }
      default:
        return Icons.battery_unknown;
    }
  }

  Color _getBatteryColor() {
    switch (_batteryState) {
      case BatteryState.charging:
        return Colors.green;
      case BatteryState.full:
        return Colors.green;
      case BatteryState.discharging:
        if (_batteryLevel <= 20) {
          return Colors.red;
        } else if (_batteryLevel <= 50) {
          return Colors.orange;
        } else {
          return Colors.green;
        }
      default:
        return Colors.grey;
    }
  }

  String _getBatteryStatusText() {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Charging • $_batteryLevel%';
      case BatteryState.full:
        return 'Fully Charged • 100%';
      case BatteryState.discharging:
        if (_batteryLevel <= 20) {
          return 'Low Battery • $_batteryLevel%';
        } else {
          return 'Discharging • $_batteryLevel%';
        }
      default:
        return 'Battery Status Unknown';
    }
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
      ) : null,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Username
                Text(
                  "Welcome, ${widget.authService.userName}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Battery Information
                Card(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          _getBatteryIcon(),
                          color: _getBatteryColor(),
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Battery Status",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getBatteryStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getBatteryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_batteryLevel%',
                            style: TextStyle(
                              color: _getBatteryColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                // Fun Snack option
                Card(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FunSnackPage(authService: widget.authService),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.casino,
                            color: const Color.fromRGBO(236, 170, 27, 1.0),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Fun Snack",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Shake your phone for random snacks!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                // Theme Toggle
                Card(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            widget.toggleTheme();
                          },
                          activeColor: const Color.fromRGBO(236, 170, 27, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Logout button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : _logout,
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Log out", style: TextStyle(fontSize: 16)),
                ),              ],
            ),
          ),
        ),
      ),
    );
  }
}