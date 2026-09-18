import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'advertise_screen.dart';
import 'contact_screen.dart';
import 'home_screen.dart';
import 'live_tv_screen.dart';
import 'news_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  Widget _bodyFor(int i) {
    switch (i) {
      case 0:
        return const HomeScreen();
      case 1:
        return const LiveTVScreen();
      case 2:
        return const NewsScreen();
      case 3:
        return const ContactScreen();
      case 4:
        return const AdvertiseScreen();
    }
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // Home has its own scrollable AppBar; others get a plain Scaffold — so we
    // just show the child directly. The bottom nav is the constant shell.
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: _bodyFor(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_outlined),
            activeIcon: Icon(Icons.live_tv),
            label: 'Live TV',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'News',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail_outlined),
            activeIcon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: _AdvertiseIcon(active: _index == 4),
            label: 'Advertise',
          ),
        ],
      ),
    );
  }
}

/// Custom "standout" icon for Advertise — filled gradient pill so it pops.
class _AdvertiseIcon extends StatelessWidget {
  final bool active;
  const _AdvertiseIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.brandRed.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: const Icon(Icons.campaign, color: Colors.white, size: 20),
    );
  }
}
