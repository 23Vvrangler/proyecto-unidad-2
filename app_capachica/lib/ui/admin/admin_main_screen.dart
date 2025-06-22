// lib/ui/admin/admin_main_screen.dart

import 'package:app_capachica/login/login_user.dart';
import 'package:flutter/material.dart';
import 'package:app_capachica/ui/admin/categoria/admin_categoria_list_screen.dart';
import 'package:app_capachica/ui/admin/lugar/admin_lugar_list_screen.dart';
import 'package:app_capachica/ui/admin/reservacion/admin_reservacion_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0; // Index for the currently selected option in the Drawer

  // List of screens to be displayed in the body based on the Drawer selection
  final List<Widget> _adminScreens = [
    const AdminCategoriaListScreen(),
    const AdminLugarListScreen(),
    const AdminReservacionListScreen(),
    // Add more admin screens here as needed (e.g., AdminUserListScreen())
  ];

  // List of titles for the AppBar, corresponding to the selected screen
  final List<String> _screenTitles = const [
    'Administrar Categorías',
    'Administrar Lugares',
    'Administrar Reservaciones',
    // Add corresponding titles here
  ];

  // Function called when a Drawer item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
      Navigator.pop(context); // Close the Drawer after selecting an option
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]), // AppBar title changes dynamically
        backgroundColor: Colors.deepPurple, // Distinct color for admin panel
        centerTitle: true,
      ),
      // The body of the screen displays the selected admin screen
      body: _adminScreens[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer header, customizable with admin info or branding
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                // OPTIONAL: Background image for the DrawerHeader.
                // Make sure 'assets/admin_drawer_bg.png' exists and is declared in pubspec.yaml.
                // If you don't want an image, you can remove this line.
                image: DecorationImage(
                  image: AssetImage('assets/admin_drawer_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white70,
                    child: Icon(Icons.shield, size: 40, color: Colors.deepPurple), // Admin icon
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Panel de Administración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Navigation options within the Drawer
            ListTile(
              leading: const Icon(Icons.category, color: Colors.blueAccent),
              title: const Text('Categorías'),
              selected: _selectedIndex == 0, // Highlight the option if selected
              onTap: () => _onItemTapped(0), // Navigate to Categories screen
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: const Text('Lugares'),
              selected: _selectedIndex == 1, // Highlight the option if selected
              onTap: () => _onItemTapped(1), // Navigate to Places screen
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.indigo),
              title: const Text('Reservaciones'),
              selected: _selectedIndex == 2, // Highlight the option if selected
              onTap: () => _onItemTapped(2), // Navigate to Reservations screen
            ),
            const Divider(), // Visual separator
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión (Admin)'),
              onTap: () async {
                // Clear all session data stored in SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // This will remove 'userId', 'token', 'userName', 'userRole', etc.

                // Close the drawer before navigating
                if (mounted) { // Ensure the widget is still mounted
                  Navigator.pop(context);
                }

                // Navigate to the login screen and remove all previous routes from the stack
                // This prevents the user from going back to the admin panel using the back button
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginUserScreen()),
                        (Route<dynamic> route) => false, // Remove all routes from the stack
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}