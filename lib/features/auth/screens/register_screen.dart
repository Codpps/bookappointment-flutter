import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doctorbooking/features/auth/screens/login_screen.dart';
import 'package:doctorbooking/features/home/screens/home_screen.dart';
import 'package:doctorbooking/core/constants/api_constants.dart';
import 'package:doctorbooking/data/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State variables
  bool _isObscure = true;
  double _passwordStrength = 0;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Password strength calculation
  void _checkPasswordStrength(String password) {
    double strength = 0;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);

    if (password.length >= 6) strength += 0.25;
    if (hasUpper) strength += 0.25;
    if (hasNumber) strength += 0.25;
    if (hasSpecial) strength += 0.25;

    setState(() => _passwordStrength = strength.clamp(0, 1));
  }

  String _getPasswordStrengthLabel(double strength) {
    if (strength <= 0.25) return "Weak";
    if (strength <= 0.5) return "Fair";
    if (strength <= 0.75) return "Good";
    return "Strong";
  }

  // Helper methods
  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
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
      suffixIcon: suffixIcon,
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Registration logic
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/Users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": _fullNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phoneNumber": _phoneController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Registration successful!", isError: false);
        if (!mounted) return;

        final user = UserModel.fromJson(result['data']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      } else {
        _handleRegistrationError(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _handleRegistrationError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRegistrationError(String error) {
    String message = "Registration failed";

    if (error.contains("email already exists")) {
      message = "Email already registered";
    } else if (error.contains("network")) {
      message = "Network error. Please check your connection";
    } else if (error.contains("weak password")) {
      message = "Password is too weak";
    }

    _showSnackBar(message);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordLevel = (_passwordStrength * 3).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Please enter a form to continue the register"),
                    const SizedBox(height: 32),

                    // Full Name Field
                    const Text("Full Name"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter your full name"
                          : null,
                      decoration: _inputDecoration("Enter your full name"),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    const Text("Email"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Enter your email"),
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    const Text("Phone Number"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter your phone number"
                          : null,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Enter your phone number"),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    const Text("Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      onChanged: _checkPasswordStrength,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        "Enter your password",
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password Strength Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getPasswordStrengthLabel(_passwordStrength),
                          style: TextStyle(
                            color: _passwordStrength < 0.5
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            final isActive = index < passwordLevel;
                            return Container(
                              width: 30,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? [
                                        Colors.red,
                                        Colors.orange,
                                        Colors.green
                                      ][index]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    const Text("Confirm Password"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      decoration: _inputDecoration("Re-enter your password"),
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2145BF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Register",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    Center(
                      child: Wrap(
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
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
      ),
    );
  }
}
