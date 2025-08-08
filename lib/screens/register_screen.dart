import 'package:doctorbooking/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isObscure = true;
  double passwordStrength = 0;

  void checkPasswordStrength(String password) {
    double strength = 0;

    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);

    if (password.length >= 6) strength += 0.25;
    if (hasUpper) strength += 0.25;

    if (hasNumber && hasSpecial) {
      strength = 0.75; // langsung dianggap "Good"
    }

    setState(() {
      passwordStrength = strength.clamp(0, 1);
    });
  }

  String _getPasswordStrengthLabel(double strength) {
    if (strength <= 0.25) return "Weak";
    if (strength <= 0.5) return "Fair";
    if (strength <= 0.75) return "Good";
    return "Strong";
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int level = 0;
    if (passwordStrength > 0) level = 1;
    if (passwordStrength >= 0.5) level = 2;
    if (passwordStrength >= 0.75) level = 3;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 36 / 24,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter a form to continue the register",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 24 / 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text("Full Name"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: fullNameController,
                    decoration: _inputDecoration("Enter your full name"),
                  ),
                  const SizedBox(height: 20),

                  const Text("Email"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration("Enter your email"),
                  ),
                  const SizedBox(height: 20),

                  const Text("Password"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: isObscure,
                    onChanged: checkPasswordStrength,
                    decoration:
                        _inputDecoration("Enter your password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(isObscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✅ Strength Label and Bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getPasswordStrengthLabel(passwordStrength),
                        style: TextStyle(
                          color: passwordStrength < 0.5
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: level >= 1 ? Colors.red : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color:
                                  level >= 2 ? Colors.orange : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color:
                                  level >= 3 ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text("Confirm Password"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Re-enter your password"),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Tambahkan logika register di sini
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2145BF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Wrap(
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF2145BF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
