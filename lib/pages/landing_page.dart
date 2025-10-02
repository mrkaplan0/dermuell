import 'package:dermuell/pages/address/select_address_page.dart';
import 'package:dermuell/pages/auth/login_page.dart';
import 'package:dermuell/pages/home_page.dart';
import 'package:dermuell/provider/auth_provider.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LandingPage extends ConsumerWidget {
  LandingPage({super.key});
  final Box myBox = Hive.box('dataBox');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var token = ref.watch(tokenProvider);

    if (token.isLoading) {
      debugPrint('Token is loading...');
      return Scaffold(body: const Center(child: MyProgressIndicator()));
    }

    if (token.hasError) {
      debugPrint('Token error: ${token.error}');
      return LoginPage();
    }

    if (token.value == null || token.value == '' || token.value!.isEmpty) {
      debugPrint('No valid token found, redirecting to LoginPage...');
      return LoginPage();
    }

    var currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
      data: (user) {
        if (user == null) {
          debugPrint('Current user is null, redirecting to LoginPage...');
          return LoginPage();
        } else {
          // User is logged in, navigate to the homepage
          if (myBox.get('address') != null) {
            debugPrint("Address found in Hive: ${myBox.get('address')}");
            return HomePage(); // Homepage
          } else if (myBox.get('collectionEvents') != null) {
            debugPrint(
              "Collection events found in Hive: ${myBox.get('collectionEvents')}",
            );
            return HomePage(); // Homepage
          } else {
            return SelectAddressPage(); // Address Selection Page
          }
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        debugPrint('Current user error: $error');
        debugPrint('Stack trace: $stack');
        // If there's an authentication error, go to login
        return LoginPage();
      },
    );
  }
}
