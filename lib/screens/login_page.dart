import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget{

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock,
              size:100,),
              const SizedBox(height: 20),
              const Text('Login to your account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 20),
              const Text('Enter your email and password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Forgot Password?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),),
              const SizedBox(height: 20),
              const Text('Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),),
              const SizedBox(height: 20),
              const Text('Don\'t have an account?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),),
              const SizedBox(height: 20),
              const Text('Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),),
            ],
          )

      )
      ),
    );
  }
}