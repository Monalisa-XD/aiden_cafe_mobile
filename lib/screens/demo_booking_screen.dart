import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DemoBookingScreen extends StatefulWidget {
  const DemoBookingScreen({super.key});

  @override
  State<DemoBookingScreen> createState() => _DemoBookingScreenState();
}

class _DemoBookingScreenState extends State<DemoBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final restaurantController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _surfaceDark = Color(0xFF0C1019);
  static const Color _surfaceBorder = Color(0xFF192233);
  static const Color _goldPrimary = Color(0xFFE5A93C);
  static const Color _textGray = Color(0xFF94A3B8);

  bool _isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    restaurantController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_goldPrimary),
        ),
      ),
    );

    final result = await ApiService.submitDemoBooking(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      restaurantName: restaurantController.text.trim(),
      phone: phoneController.text.trim(),
      message: messageController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context); // Pop dialog

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      // Clear form
      nameController.clear();
      emailController.clear();
      restaurantController.clear();
      phoneController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demo request submitted successfully! We'll contact you soon."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? "Failed to submit demo request"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text(
          "BOOK A DEMO",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Request Private Demo",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Schedule a personalized walk-through of the platform tailored specifically to your establishment's operational needs.",
                  style: TextStyle(
                    fontSize: 15,
                    color: _textGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Name Input
                _buildInputField(
                  label: "YOUR NAME",
                  hint: "e.g., Sanjay Prabhakar",
                  controller: nameController,
                  validator: (val) => val == null || val.trim().isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 20),

                // Email Input
                _buildInputField(
                  label: "BUSINESS E-MAIL",
                  hint: "e.g., sanjay@aidencafe.com",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Email is required";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Restaurant Name Input
                _buildInputField(
                  label: "ESTABLISHMENT NAME",
                  hint: "e.g., South Kitchen",
                  controller: restaurantController,
                  validator: (val) => val == null || val.trim().isEmpty ? "Establishment name is required" : null,
                ),
                const SizedBox(height: 20),

                // Phone Input
                _buildInputField(
                  label: "CONTACT PHONE",
                  hint: "e.g., +91 98765 43210",
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.trim().isEmpty ? "Phone number is required" : null,
                ),
                const SizedBox(height: 20),

                // Message Input
                _buildInputField(
                  label: "MESSAGE / SPECIAL REQUESTS",
                  hint: "e.g., Tell us about your locations or requirements...",
                  controller: messageController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldPrimary,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: _goldPrimary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "SCHEDULE BRIEFING",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC2B9AD),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4F5E75), fontSize: 14),
            fillColor: _surfaceDark,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _surfaceBorder, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _goldPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
