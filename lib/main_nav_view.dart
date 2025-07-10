import 'package:bili_sense/presentation/all_mothers/all_mothers_view.dart';
import 'package:bili_sense/presentation/home/home_view.dart';
import 'package:bili_sense/presentation/profile/profile_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  final GlobalKey _bottomNavigationKey = GlobalKey();

  final List<String> _titles = const ['Home', 'All Mothers', 'Profile'];

  Widget setUpBottomNavigation(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return HomeView();
      case 1:
        return AllMothersView();
      case 2:
        return ProfileView();
      default:
        return HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), elevation: 5),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        color: Colors.teal,
        buttonBackgroundColor: Colors.black87,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) => setState(() => _currentIndex = index),
        index: _currentIndex,
        items: [
          const Icon(Icons.home, size: 30, color: Colors.white),
          const Icon(Icons.search, size: 30, color: Colors.white),
          const Icon(Icons.perm_identity, size: 30, color: Colors.white),
        ],
      ),
      body: setUpBottomNavigation(_currentIndex),
    );
  }
}
