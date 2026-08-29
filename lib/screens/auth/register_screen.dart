import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController(text: "The Gilded Table");
  final TextEditingController emailController =
      TextEditingController(text: "proprietor@aidencafe.com");
  final TextEditingController passwordController =
      TextEditingController(text: "••••••••");
  final TextEditingController confirmController =
      TextEditingController(text: "••••••••");

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Color Palette from Screenshots
  static const Color _bgCream = Color(0xFFFAFAFA);
  static const Color _cardCream = Color(0xFFF7F3EE);
  static const Color _cardBorder = Color(0xFFEFE8DE);
  static const Color _textDark = Color(0xFF2D2115);
  static const Color _textGray = Color(0xFF7E7367);
  static const Color _labelGray = Color(0xFF9E9182);
  static const Color _amberPrimary = Color(0xFFC68A1E);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Header Navigation Bar
              _buildTopNavBar(),

              const SizedBox(height: 60),

              // Center Registration Form Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Configure your digital profile securely to join the network.",
                            style: TextStyle(
                              fontSize: 14,
                              color: _textGray,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Restaurant Name Input Field
                          _buildCustomInputField(
                            label: "RESTAURANT NAME",
                            controller: nameController,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          // Email Address Input Field
                          _buildCustomInputField(
                            label: "EMAIL ADDRESS",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password Input Field
                          _buildCustomInputField(
                            label: "PASSWORD",
                            controller: passwordController,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textDark,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Input Field
                          _buildCustomInputField(
                            label: "CONFIRM",
                            controller: confirmController,
                            obscureText: obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textDark,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // INITIALIZE ESTABLISHMENT Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB87612),
                                    Color(0xFF8C4E0A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB87612)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (passwordController.text != confirmController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Passwords do not match"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Show loading spinner
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(_amberPrimary),
                                        ),
                                      ),
                                    );

                                    final result = await ApiService.register(
                                      nameController.text.trim(),
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    if (result['success'] == true) {
                                      await context.read<AuthProvider>().login(result['token'], result['user']);
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Establishment ${nameController.text} Registered!"),
                                        ),
                                      );
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['error'] ?? "Registration failed"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "INITIALIZE ESTABLISHMENT",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Terms Disclaimer
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC2B9AD),
                                  letterSpacing: 1.2,
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(text: "BY INITIALIZING, YOU AGREE TO THE\n"),
                                  TextSpan(
                                    text: "RESTAURANT TERMS OF SERVICE",
                                    style: TextStyle(color: Color(0xFFA05A10)),
                                  ),
                                  TextSpan(text: " AND "),
                                  TextSpan(
                                    text: "PRIVACY SANCTUM.",
                                    style: TextStyle(color: Color(0xFFA05A10)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Tabs (LOGIN & REGISTER YOUR RESTAURANT)
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    color: _labelGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "REGISTER YOUR RESTAURANT",
                    style: TextStyle(
                      color: _amberPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2,
                    width: 190,
                    color: _amberPrimary,
                  ),
                ],
              ),
            ],
          ),

          // Right Link (WEBSITE)
          InkWell(
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Row(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: _labelGray,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "WEBSITE",
                  style: TextStyle(
                    color: _labelGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _labelGray,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              ?suffixIcon,
            ],
          ),
        ],
      ),
    );
  }
}
