import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/booking_enquiry.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _surfaceDark = Color(0xFF0C1019);
  static const Color _surfaceBorder = Color(0xFF192233);
  static const Color _goldPrimary = Color(0xFFE5A93C);
  static const Color _textGray = Color(0xFF94A3B8);

  TabController? _tabController;
  List<BookingEnquiry> _demoBookings = [];
  List<BookingEnquiry> _enquiries = [];
  bool _isLoadingData = false;
  String? _dataError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoadingData = true;
      _dataError = null;
    });

    try {
      final demos = await ApiService.getDemoBookings();
      final enqs = await ApiService.getEnquiries();
      if (mounted) {
        setState(() {
          _demoBookings = demos;
          _enquiries = enqs;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dataError = 'Failed to load bookings: ${e.toString()}';
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If unauthenticated, show the LoginScreen
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final user = auth.user;
    final canManage = user?.canManage ?? false;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text(
          "ACCOUNT & MANAGEMENT",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: "Sign Out",
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Signed out successfully.")),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _surfaceBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _goldPrimary.withValues(alpha: 0.15),
                        border: Border.all(color: _goldPrimary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: _goldPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: _textGray,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _goldPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user?.role ?? 'CUSTOMER',
                              style: const TextStyle(
                                color: _goldPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // If OWNER or ADMIN, render dashboard view
              if (canManage) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ADMIN DASHBOARD",
                      style: TextStyle(
                        color: Color(0xFFC2B9AD),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoadingData ? null : _loadAdminData,
                      icon: const Icon(Icons.refresh, size: 16, color: _goldPrimary),
                      label: const Text("Refresh", style: TextStyle(color: _goldPrimary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tab Selector
                TabBar(
                  controller: _tabController,
                  indicatorColor: _goldPrimary,
                  labelColor: _goldPrimary,
                  unselectedLabelColor: _textGray,
                  tabs: [
                    Tab(text: "DEMO BOOKINGS (${_demoBookings.length})"),
                    Tab(text: "ENQUIRIES (${_enquiries.length})"),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isLoadingData)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: _goldPrimary),
                    ),
                  )
                else if (_dataError != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(_dataError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadAdminData,
                            style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary),
                            child: const Text("RETRY", style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Direct inline list based on selected tab
                  AnimatedBuilder(
                    animation: _tabController!,
                    builder: (context, _) {
                      final isEnquiries = _tabController!.index == 1;
                      final list = isEnquiries ? _enquiries : _demoBookings;

                      if (list.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  isEnquiries ? Icons.mail_outline : Icons.calendar_today_outlined,
                                  color: _textGray.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isEnquiries ? "No catering enquiries yet." : "No demo bookings yet.",
                                  style: const TextStyle(color: _textGray, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _loadAdminData,
                                  child: const Text("Load data from server", style: TextStyle(color: _goldPrimary)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _surfaceDark,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _surfaceBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item.type,
                                      style: TextStyle(
                                        color: item.isDemo ? _goldPrimary : const Color(0xFF38BDF8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Establishment: ${item.restaurantName}",
                                  style: const TextStyle(color: _textGray, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Phone: ${item.phone} | Email: ${item.email}",
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                                if (item.message.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.message,
                                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Signed out successfully.")),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "LOG OUT OF SESSION",
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
