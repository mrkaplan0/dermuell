import 'package:dermuell/pages/address/select_address_page.dart';
import 'package:dermuell/pages/auth/login_page.dart';
import 'package:dermuell/provider/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? extraActionButton;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.extraActionButton,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontFamily: 'FingerPaint')),
      actions: [
        if (extraActionButton != null) extraActionButton!,
        if (extraActions != null) ...extraActions!,
        _buildMenuAnchor(context, ref),
      ],
    );
  }

  Widget _buildMenuAnchor(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      menuChildren: [
        _buildSettingsMenuItem(context),
        _buildLogoutMenuItem(context, ref),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert),
              tooltip: 'Show menu',
            );
          },
    );
  }

  Widget _buildSettingsMenuItem(BuildContext context) {
    return MenuItemButton(
      trailingIcon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectAddressPage(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Text('Einstellungen'.tr()),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      trailingIcon: const Icon(Icons.logout),
      onPressed: () async {
        await ref.read(authServiceProvider).logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Text('Abmelden'.tr()),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
