import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_keyboard/pin_keyboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithGoogle();
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed. Please try again.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: $error')),
        );
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;

    if (!isBiometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric login is not enabled.')),
      );
      return;
    }

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
      );
      if (didAuthenticate) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showKeypad() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PinKeyboard(
          length: 4,
          enableBiometric: true,
          iconBiometricColor: Colors.blue[400],
          onChange: (pin) {
            // Handle PIN change
          },
          onConfirm: (pin) {
            // Handle PIN confirm
            Navigator.pop(context);
          },
          onBiometric: () {
            _authenticateWithBiometrics();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiter App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Username/ID'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            const Text('Or login with'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _authenticateWithBiometrics,
                  child: const Text('Biometric'),
                ),
                ElevatedButton(
                  onPressed: _showKeypad,
                  child: const Text('Keypad'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}