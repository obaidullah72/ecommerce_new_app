import 'package:ecommerce_new_app/provider/cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;  // Import badges package

import '../provider/themeprovider.dart';
import 'cartscreen.dart';
import 'favouritescreen.dart';
import 'homescreen.dart';
import 'orderscreen.dart';
import 'profilescreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Size size = Size.zero;
  int currentIndex = 0;
  final navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _buildScreens = [
    const HomeScreen(),
    const FavouriteScreen(),
    const CartScreen(),
    const OrderScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = themeProvider.isDarkMode
        ? ThemeData.dark().colorScheme
        : ThemeData.light().colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          _buildScreens[currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            getIcon(0, "Home", Iconsax.home_14),
            getIcon(1, "Favourite", Iconsax.heart),
            getCartIcon(),
            getIcon(3, "Orders", CupertinoIcons.list_bullet_indent),
            getIcon(4, "Profile", Iconsax.profile_circle4),
          ],
          currentIndex: currentIndex,
          onTap: (int tab) {
            setState(() {
              currentIndex = tab;
            });
          },
        ),
      ),
    );
  }

  // Helper function to create a BottomNavigationBarItem
  BottomNavigationBarItem getIcon(int i, String label, IconData icon) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.only(
          bottom: 2,
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  // Special Cart Icon with Badge
// Special Cart Icon with Badge
  BottomNavigationBarItem getCartIcon() {
    bool hasProducts = context.watch<CartProvider>().shoppingCart.isNotEmpty;

    return BottomNavigationBarItem(
      icon: badges.Badge(
        showBadge: hasProducts, // Only show the badge if there are products
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.redAccent,
        ),
        badgeContent: Text(
          context.watch<CartProvider>().shoppingCart.length.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasProducts || currentIndex == 2
                  ? Theme.of(context).colorScheme.primary // Dynamic color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Unselected color
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Icon(
              Iconsax.bag,
              color: hasProducts || currentIndex == 2
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 22,
            ),
          ),
        ),
      ),
      label: "Cart",
    );
  }
}
