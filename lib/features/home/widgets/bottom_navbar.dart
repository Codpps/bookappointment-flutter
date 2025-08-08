import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue, // warna aktif
      unselectedItemColor: Colors.grey, // warna non-aktif
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(BootstrapIcons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(BootstrapIcons.calendar),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(BootstrapIcons.clock_history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(BootstrapIcons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(BootstrapIcons.person),
          label: 'Account',
        ),
      ],
    );
  }
}
