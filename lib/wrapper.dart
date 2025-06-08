// filepath: c:\Flutter Projects\crunchzone\lib\wrapper.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login.dart';
import 'home.dart';
import 'pages/admin/admin_main_page.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final AuthService authService;

  const AuthWrapper({
    Key? key, 
    required this.toggleTheme, 
    required this.themeMode, 
    required this.authService
  }) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen for authentication changes
    widget.authService.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    widget.authService.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    // Force rebuild when auth state changes
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (widget.authService.isLoggedIn) {      // Check if user is admin
      if (widget.authService.isAdmin) {
        // Show admin dashboard
        return AdminMainPage(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
          authService: widget.authService,
        );
      } else {
        // User is logged in but not admin, show main app
        return HomePage(
          toggleTheme: widget.toggleTheme,
          themeMode: widget.themeMode,
          authService: widget.authService,
        );
      }
    } else {
      // User is not logged in, show login page
      return LoginPage(
        toggleTheme: widget.toggleTheme,
        themeMode: widget.themeMode,
        authService: widget.authService,
      );
    }
  }
}