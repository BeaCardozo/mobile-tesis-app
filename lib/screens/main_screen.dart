import 'package:flutter/material.dart';
import '../services/cart_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _selectedCurrency = 'Bs';

  void _onCurrencyChanged(String newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
    });
  }

  @override
  void initState() {
    super.initState();
    CartManager.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            selectedCurrency: _selectedCurrency,
            onCurrencyChanged: _onCurrencyChanged,
          ),
          ProductsScreen(
            selectedCurrency: _selectedCurrency,
            onCurrencyChanged: _onCurrencyChanged,
          ),
          OffersScreen(
            selectedCurrency: _selectedCurrency,
            onCurrencyChanged: _onCurrencyChanged,
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
