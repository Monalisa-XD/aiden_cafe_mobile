import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController(text: "maitred@aidencafe.com");
  final TextEditingController passwordController =
      TextEditingController(text: "••••••••");

  bool obscurePassword = true;
  bool rememberDevice = false;

  // Colors matching reference image
  static const Color _bgCream = Color(0xFFFAFAFA);
  static const Color _cardCream = Color(0xFFF7F3EE);
  static const Color _cardBorder = Color(0xFFEFE8DE);
  static const Color _textDark = Color(0xFF2D2115);
  static const Color _textGray = Color(0xFF7E7367);
  static const Color _labelGray = Color(0xFF9E9182);
  static const Color _amberPrimary = Color(0xFFC68A1E);
  static const Color _amberDark = Color(0xFF8C4E0A);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showQuickLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F5F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chevron Drag Indicator
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFA89B8C),
                size: 24,
              ),
              const SizedBox(height: 12),

              // Title
              const Text(
                "QUICK LOGIN",
                style: TextStyle(
                  color: Color(0xFFA89B8C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),

              // User Quick Login Card
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    emailController.text = "sanjay@aidencafe.com";
                    passwordController.text = "password123";
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Quick Login selected: Sanjay Prabhakar"),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar S
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFBF0),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "S",
                            style: TextStyle(
                              color: Color(0xFFD99B26),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name & Role
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sanjay Prabhakar",
                              style: TextStyle(
                                color: Color(0xFF2B1D0E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "OWNER",
                              style: TextStyle(
                                color: Color(0xFFA39687),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow Icon
                      const Icon(
                        Icons.east_rounded,
                        color: Color(0xFFC4BBAF),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Top Navbar (LOGIN, REGISTER YOUR RESTAURANT, WEBSITE)
                  _buildTopNavBar(),

                  const SizedBox(height: 60),

                  // Center Form Card
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
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: _textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Enter your credentials to access the Restaurant dashboard.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textGray,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 36),

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
                              const SizedBox(height: 20),

                              // Checkbox & Forgot Password Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        rememberDevice = !rememberDevice;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF8A7B6C),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: rememberDevice
                                                ? _amberPrimary
                                                : Colors.transparent,
                                          ),
                                          child: rememberDevice
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "REMEMBER DEVICE",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF594B3C),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "FORGOT ACCESS?",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFA05A10),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // SIGN IN Button
                              InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Show progress indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(_amberPrimary),
                                        ),
                                      ),
                                    );

                                    final result = await ApiService.login(
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    if (result['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Welcome back, ${result['user']['name']}!",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['error'] ?? "Sign In Failed",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB87612),
                                        _amberDark,
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
                                  alignment: Alignment.center,
                                  height: 54,
                                  child: const Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Footer Notes
                  const Text(
                    "SECURELY ENCRYPTED BY AIDEN-GUARD™",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC2B9AD),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "© 2026 AIDEN CAFE. ALL RIGHTS RESERVED.",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC2B9AD),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Floating Key Action Button (Bottom Right)
          Positioned(
            bottom: 32,
            right: 24,
            child: InkWell(
              onTap: _showQuickLoginBottomSheet,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: Color(0xFFA06810),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "LOGIN",
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
                    width: 32,
                    color: _amberPrimary,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "REGISTER YOUR RESTAURANT",
                  style: TextStyle(
                    color: _labelGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // Right Link (WEBSITE)
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
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
