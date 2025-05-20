import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';
import 'package:firebase_flutter_notification/views/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/register');
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    setState(() => _isProcessing = true);

    try {
      await viewModel.signIn(
          _emailController.text.trim(), _passwordController.text.trim());

      if (!mounted) return;

      if (viewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Wait for auth state to be fully updated
      await Future.delayed(const Duration(milliseconds: 500));

      if (viewModel.currentUser != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MyHomePage(),
              settings: const RouteSettings(name: 'home'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Consumer<AuthViewModel>(
            builder: (context, viewModel, _) {
              return ListView(
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration:
                              const InputDecoration(label: Text('Email')),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isProcessing &&
                              !viewModel.isProcessingNotification,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(label: Text('Password')),
                          enabled: !_isProcessing &&
                              !viewModel.isProcessingNotification,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed:
                        (_isProcessing || viewModel.isProcessingNotification)
                            ? null
                            : signIn,
                    child: (_isProcessing || viewModel.isProcessingNotification)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: (_isProcessing ||
                                viewModel.isProcessingNotification)
                            ? null
                            : navigateRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
