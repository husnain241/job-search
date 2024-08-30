import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/Profile%20Components/Logine.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  // Define the pages for each tab
  final List<Widget> _pages = [
    Center(child: Text('Welcome to the Home Page!')),
  ];

  void _onTabTapped(int index) {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text('Home'),
              actions: [
                if (user != null)
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
