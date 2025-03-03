import 'package:dermalens/screens/auth/signup_page.dart';
import 'package:dermalens/screens/user/dashboard_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFfefeff),

        //AppBar
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFfefeff),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pop(context);
              }),
          iconTheme: const IconThemeData(
            color: Color(0xFF986A2F),
          ),
          elevation: 0,
          title: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFF986A2F),
              fontSize: 24,
              fontFamily: 'LeagueSpartan',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        //Body
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/dermalens.png',
                    width: 250,
                    height: 200,
                  ),
                  // const SizedBox(height: 16),

                  const SizedBox(height: 32),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email ID',
                      labelStyle: TextStyle(
                        color: Color(0xFF986A2F),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF986A2F)),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF986A2F),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF986A2F)),
                      ),
                      suffixIcon: Icon(
                        Icons.visibility_off,
                        color: Color(0xFF986A2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF986A2F),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle login
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF986A2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      label: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Don’t have an account?',
                    style: TextStyle(
                      color: Color(0xFF070707),
                      fontSize: 12,
                      fontFamily: 'LeagueSpartan',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  TextButton(
                    style: TextButton.styleFrom(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF0966FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
