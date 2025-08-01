import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:vpnprowithjava/utils/my_icons_icons.dart';
import '../home_screen.dart';
import '../more_screen.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const MoreScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(
          MyIcons.shield_check_outline,
          color: Colors.green,
        ),
        inactiveIcon: const Icon(
          MyIcons.shield_check_outline,
          color: Colors.white,
        ),
        title: ('VPN'),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          MyIcons.more_01__1_,
          color: Colors.green,
          size: 23,
        ),
        inactiveIcon: const Icon(
          MyIcons.more_01__1_,
          color: Colors.white,
          size: 20,
        ),
        title: ('More'),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.white,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      hideNavigationBarWhenKeyboardShows: false,
      popAllScreensOnTapAnyTabs: true,
      screens: _buildScreens(),
      items: _navBarsItems(),
      onItemSelected: (item) {
        controller.index = item;
        setState(() {});
      },
      backgroundColor: Colors.grey.shade900,
      decoration: const NavBarDecoration(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        colorBehindNavBar: Color.fromARGB(255, 238, 231, 231),
      ),
      navBarStyle: NavBarStyle.style6,
    );
  }
}
