import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../utils/role_redirect.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final AuthService authService = AuthService();

  bool loading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 90, 161, 241),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// Email Field
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF1565C0),
                        ),
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Password Field
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF1565C0),
                        ),
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Error Message
                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white, // 🔥 TEXT COLOR FIX
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  error = '';
                                });

                                try {
                                  await authService.loginUser(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RoleRedirect(),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    error = "Invalid email or password";
                                  });
                                }

                                setState(() => loading = false);
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // 🔥 EXTRA SAFETY
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Register Link
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
