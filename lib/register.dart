import 'package:flutter/material.dart';
import 'login.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;

  RegisterPage({required this.toggleTheme, required this.themeMode, required this.authService});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

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

      //  Body 
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                bool isWideScreen = screenWidth > 600;

                return Card(
                  color: isDarkMode ? Colors.white : Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 400 : double.infinity,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Center(
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          _buildInputField("Username", _usernameController, isDarkMode),
                          SizedBox(height: 15),

                          _buildInputField("Email", _emailController, isDarkMode),
                          SizedBox(height: 15),

                          _buildInputField("Password", _passwordController, isDarkMode, obscureText: true),
                          SizedBox(height: 15),

                          _buildInputField("Confirm Password", _confirmPasswordController, isDarkMode, obscureText: true),
                          SizedBox(height: 20),

                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),                              onPressed: _isLoading ? null : () async {
                                
                                String username = _usernameController.text.trim();
                                String email = _emailController.text.trim();
                                String password = _passwordController.text.trim();
                                String confirmPassword = _confirmPasswordController.text.trim();
                                
                                // Validate inputs
                                if (username.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Username is required"))
                                  );
                                  return;
                                }
                                
                                if (email.isEmpty || !email.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter a valid email address"))
                                  );
                                  return;
                                }
                                
                                if (password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Password is required"))
                                  );
                                  return;
                                }
                                
                                if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Passwords don't match"))
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  // Register the user
                                  bool success = await widget.authService.register(
                                    email,
                                    password,
                                    username
                                  );
                                    if (success) {
                                    // No need to navigate, the AuthWrapper will detect the login
                                    // and automatically show the HomePage
                                  } else {
                                    // Show error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Registration failed. Please try again."))
                                    );
                                  }
                                } catch (e) {
                                  // Show error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: ${e.toString()}"))
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              child: _isLoading 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),

                          SizedBox(height: 20),

                          Center(
                            child: GestureDetector(
                              onTap: () {                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(
                                        toggleTheme: widget.toggleTheme,
                                        themeMode: widget.themeMode,
                                        authService: widget.authService,
                                      ),
                                    ),
                                  );
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.black : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField(String label, TextEditingController controller, bool isDarkMode, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.black : Colors.black),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "Enter your $label",
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
