import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_notification/viewmodels/home_viewmodel.dart';
import 'package:firebase_flutter_notification/views/account_page.dart';
import 'package:firebase_flutter_notification/views/notes_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(context.read()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.error != null) {
          return Scaffold(
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

        var colorScheme = Theme.of(context).colorScheme;

        Widget page;
        switch (viewModel.currentIndex) {
          case 0:
            page = const NotesPage();
          case 1:
            page = const AccountPage();
          default:
            throw UnimplementedError('no widget for ${viewModel.currentIndex}');
        }

        var mainArea = ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: page,
          ),
        );

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 450) {
                return Column(
                  children: [
                    Expanded(child: mainArea),
                    SafeArea(
                      child: BottomNavigationBar(
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person),
                            label: 'Account',
                          ),
                        ],
                        currentIndex: viewModel.currentIndex,
                        onTap: viewModel.setCurrentIndex,
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        extended: constraints.maxWidth >= 600,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text('Account'),
                          ),
                        ],
                        selectedIndex: viewModel.currentIndex,
                        onDestinationSelected: viewModel.setCurrentIndex,
                      ),
                    ),
                    Expanded(child: mainArea),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }
}
