import 'package:dermuell/const/constants.dart';
import 'package:dermuell/pages/nav_pages/messages_page.dart';
import 'package:dermuell/pages/nav_pages/waste_management_page.dart';
import 'package:dermuell/widgets/custom_navigation_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<GlobalKey> destinationKeys;
  late final List<AnimationController> destinationFaders;
  late final List<Widget> destinationViews;
  int selectedIndex = 0;

  void _onNavigationItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(selectedIndex);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: XConst.bgColor,
        selectedIndex: selectedIndex,
        onDestinationSelected: _onNavigationItemTap,
        destinations: [
          CustomNavigationItem(
            itemIndex: 0,
            selectedIndex: selectedIndex,
            icon: Icons.home,
            label: 'Home',
            onTap: () => _onNavigationItemTap(0),
          ),
          CustomNavigationItem(
            itemIndex: 1,
            selectedIndex: selectedIndex,
            icon: Icons.delete,
            label: 'Dein Müll',
            onTap: () => _onNavigationItemTap(1),
          ),
        ],
      ),

      body:
          <Widget>[
            MessagesPage(), //  Messages Page
            WasteManagement(), //Dein Müll Page
          ][selectedIndex].animate().fadeIn(
            duration: 500.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
