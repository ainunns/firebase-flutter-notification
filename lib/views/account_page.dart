import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_notification/viewmodels/account_viewmodel.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';
import 'package:firebase_flutter_notification/views/login_page.dart';
import 'package:firebase_flutter_notification/services/notification.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountViewModel(context.read<AuthViewModel>()),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.error != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Account Information'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  ElevatedButton(
                    onPressed: viewModel.clearError,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = viewModel.currentUser;
        if (user == null) {
          return const LoginPage();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Account Information'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final authViewModel = context.read<AuthViewModel>();
                      await authViewModel.signOut();

                      // Send logout notification
                      await NotificationService.createNotification(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .remainder(100000),
                        title: 'Logged Out',
                        body:
                            'You have been successfully logged out. See you next time!',
                        payload: {
                          'type': 'logout',
                          'email': user.email,
                        },
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
