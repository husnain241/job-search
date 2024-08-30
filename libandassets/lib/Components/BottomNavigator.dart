import 'package:flutter/material.dart';
import 'package:my_flutter_app/Jobs/ListAllJobs.dart';
import 'package:my_flutter_app/Jobs/SearchJob.dart';
import 'package:my_flutter_app/Jobs/PostAJob.dart';
import 'package:my_flutter_app/Profile%20Components/ProfilePage.dart';

class BottomNavigatorExample extends StatefulWidget {
  @override
  _BottomNavigatorExampleState createState() => _BottomNavigatorExampleState();
}

class _BottomNavigatorExampleState extends State<BottomNavigatorExample> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Color.fromARGB(255, 3, 53, 41),
      ),
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Person',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => jobsList()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobSearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobPostingPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobProfilePage()),
            );
          }
        },
      ),
    );
  }
}
