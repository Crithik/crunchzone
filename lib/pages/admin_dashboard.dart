import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'admin/admin_products_page.dart';
import 'admin/admin_categories_page.dart';
import 'admin/product_form_page.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;

  const AdminDashboard({
    Key? key,
    required this.toggleTheme,
    required this.themeMode,
    required this.authService,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
            const Text(
              "Admin Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.black,
                  ),
                  onPressed: widget.toggleTheme,
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () async {
                    await widget.authService.logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${widget.authService.userName}!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Admin Dashboard - CrunchZone",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Total Users",
                    "156",
                    Icons.people,
                    Colors.blue,
                    isDarkMode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Total Orders",
                    "342",
                    Icons.shopping_bag,
                    Colors.green,
                    isDarkMode,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Products",
                    "89",
                    Icons.inventory,
                    Colors.orange,
                    isDarkMode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Revenue",
                    "₹45,230",
                    Icons.attach_money,
                    Colors.purple,
                    isDarkMode,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Management Options
            Text(
              "Management",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
              _buildManagementOption(
              "Manage Products",
              "Add, edit, or remove products",
              Icons.inventory_2,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProductsPage(authService: widget.authService),
                  ),
                );
              },
              isDarkMode,
            ),
            
            _buildManagementOption(
              "Manage Categories",
              "Add, edit, or remove categories",
              Icons.category,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminCategoriesPage(authService: widget.authService),
                  ),
                );
              },
              isDarkMode,
            ),
            
            _buildManagementOption(
              "Manage Orders",
              "View and manage customer orders",
              Icons.receipt_long,
              () {
                // TODO: Navigate to order management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order management coming soon!')),
                );
              },
              isDarkMode,
            ),
            
            _buildManagementOption(
              "Manage Users",
              "View and manage user accounts",
              Icons.people_alt,
              () {
                // TODO: Navigate to user management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon!')),
                );
              },
              isDarkMode,
            ),
            
            _buildManagementOption(
              "Reports & Analytics",
              "View sales reports and analytics",
              Icons.analytics,
              () {
                // TODO: Navigate to analytics
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon!')),
                );
              },
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromRGBO(236, 170, 27, 1.0)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}