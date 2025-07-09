import 'package:bili_sense/presentation/all_mothers/all_mothers_view.dart';
import 'package:bili_sense/presentation/home/home_view.dart';
import 'package:bili_sense/presentation/profile/profile_view.dart';
import 'package:flutter/material.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    AllMothersView(),
    ProfileView(),
  ];

  final List<String> _titles = const ['Home', 'All Mothers', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), elevation: 5),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: '',
          ),
        ],
      ),
    );
  }
}
