import 'package:flutter/material.dart';
import 'package:the_admin_panal/auth/auth_controller.dart';
import 'package:the_admin_panal/home/home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Container(
          color: Colors.grey[200],
          height: 300,
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: () {
                    AuthController authController = AuthController();
                    if (emailController.text != 'admin@admin.admin') {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Error'),
                                content:
                                    const Text('Invalid Email or Password'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Ok'))
                                ],
                              ));
                      return;
                    } else {
                      debugPrint('Email is correct');
                      authController
                          .signInWithEmailAndPassword(
                              emailController.text, passwordController.text)
                          .whenComplete(() {
                        debugPrint(authController.user.toString());
                        if (authController.user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(),
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
