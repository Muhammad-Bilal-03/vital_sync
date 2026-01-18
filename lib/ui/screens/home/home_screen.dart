// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../models/test_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../repositories/test_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/speed_dial_fab.dart';
import '../booking/booking_screen.dart';
import '../booking/lab_booking_screen.dart'; // Ensure this import is here
import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const DashboardView(), // Must be the Stateful DashboardView
    const OrdersScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SpeedDialFab(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 20, color: Colors.black.withValues(alpha: 0.05))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: VitalColors.softTeal,
              hoverColor: VitalColors.softTeal,
              gap: 8,
              activeColor: VitalColors.oceanTeal,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: VitalColors.oceanTeal.withValues(alpha: 0.1),
              color: Colors.grey[600],
              tabs: const [
                GButton(icon: LucideIcons.layoutDashboard, text: 'Home'),
                GButton(icon: LucideIcons.testTube2, text: 'Orders'),
                GButton(icon: LucideIcons.bell, text: 'Alerts'),
                GButton(icon: LucideIcons.user, text: 'Profile'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}

// --- STATEFUL DASHBOARD VIEW (This holds the Toggle Logic) ---
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isHomeVisit = true; // State for the toggle

  // Logic to handle Banner Click
  void _handleBannerClick(BuildContext context) async {
    final repo = TestRepository();
    try {
      final tests = await repo.getPopularTests();
      final promoPackage =
          tests.firstWhere((t) => t.name.contains("Full Body Checkup"));

      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).addTest(promoPackage);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Promo Package added!"),
          backgroundColor: VitalColors.oceanTeal,
          duration: Duration(seconds: 2),
        ));
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CartScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Offer not available yet."),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final cartItemCount = Provider.of<CartProvider>(context).items.length;
    final testRepo = TestRepository();

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [VitalColors.background, Color(0xFFE8F5E9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Good Morning,",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                    Text(user?.firstName ?? "Guest",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: VitalColors.midnightBlue)),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                    icon: const Icon(LucideIcons.shoppingCart,
                        color: VitalColors.midnightBlue),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text(cartItemCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                          .animate()
                          .scale(duration: 200.ms, curve: Curves.easeOutBack),
                    )
                ],
              )
            ],
          ).animate().fadeIn().moveY(begin: -10, end: 0),

          const SizedBox(height: 24),

          // --- 2. THE TOGGLE (Restored) ---
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Row(
              children: [
                _buildToggleOption("Home Visit", _isHomeVisit, () {
                  setState(() => _isHomeVisit = true);
                }),
                _buildToggleOption("Lab Visit", !_isHomeVisit, () {
                  setState(() => _isHomeVisit = false);
                }),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // --- 3. Clickable Banner ---
          GestureDetector(
            onTap: () => _handleBannerClick(context),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80"),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.black38, BlendMode.darken),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ]),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: VitalColors.oceanTeal,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("LIMITED OFFER",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Text("50% OFF",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900)),
                  const Text("Tap to claim Full Body Checkup",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),

          const SizedBox(height: 30),

          // --- 4. Dynamic Content (Home vs Lab) ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isHomeVisit
                ? _buildHomeVisitContent(context)
                : _buildLabVisitContent(context),
          ),

          const SizedBox(height: 30),

          // --- 5. Packages Section ---
          const _SectionHeader(title: "Packages & Bundles"),
          const SizedBox(height: 12),

          FutureBuilder<List<TestModel>>(
              future: testRepo.getPopularTests(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final packages = snapshot.data!
                    .where((t) => t.category == 'Package')
                    .toList();

                if (packages.isEmpty)
                  return const Text("No packages available.");

                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final pack = packages[index];
                        return Container(
                          width: 260,
                          margin: const EdgeInsets.only(right: 16),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            onTap: () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .addTest(pack);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text("${pack.name} added!"),
                                      backgroundColor: VitalColors.oceanTeal,
                                      duration: const Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: "CHECKOUT",
                                        textColor: Colors.white,
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const CartScreen())),
                                      )));
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.25, // Better Visibility
                                    child: Image.network(
                                      "https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: VitalColors.electricBlue
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                                LucideIcons.package,
                                                color: VitalColors.electricBlue,
                                                size: 20),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Text("PROMO",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(pack.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text("PKR ${pack.price.toInt()}",
                                              style: const TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                          const SizedBox(width: 8),
                                          Text(
                                              "PKR ${pack.discountedPrice?.toInt()}",
                                              style: const TextStyle(
                                                  color: VitalColors.oceanTeal,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }),

          const SizedBox(height: 30),

          // --- 6. Active Reports ---
          _buildActiveReports(context),

          const SizedBox(height: 30),

          // --- 7. Popular Tests ---
          const _SectionHeader(title: "Popular Tests"),
          const SizedBox(height: 12),
          _buildIndividualTests(testRepo),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildToggleOption(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? VitalColors.midnightBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color:
                              VitalColors.midnightBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : []),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHomeVisitContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassCard(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BookingScreen())),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: VitalColors.oceanTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.calendarPlus,
                    color: VitalColors.oceanTeal),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Book Home Collection",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: VitalColors.midnightBlue)),
                    Text("Phlebotomist visits your home",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.grey)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabVisitContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Nearest Labs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("See Map",
                style: TextStyle(color: VitalColors.oceanTeal, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        _buildLabTile(context, "Al Hamra Clinic", "7636 Abu Hurairah, Al Hamra",
            "3.4 km"),
        const SizedBox(height: 12),
        _buildLabTile(
            context, "City Medical Lab", "Block B, Satellite Town", "5.1 km"),
      ],
    );
  }

  Widget _buildLabTile(
      BuildContext context, String name, String address, String distance) {
    return GlassCard(
      // Correctly Navigates to LabBookingScreen
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LabBookingScreen(labName: name, labAddress: address))),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                    image: NetworkImage(
                        "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=200&q=80"),
                    fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(address,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(LucideIcons.mapPin,
                  size: 16, color: VitalColors.oceanTeal),
              Text(distance,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActiveReports(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final activeOrders = orderProvider.orders
            .where((o) => o.status == 'Processing' || o.status == 'Scheduled')
            .toList();

        if (activeOrders.isEmpty) return const SizedBox.shrink();

        final latestOrder = activeOrders.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Active Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(latestOrder.testName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(latestOrder.status,
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: Colors.grey[200],
                      color: VitalColors.oceanTeal,
                      borderRadius: BorderRadius.circular(10)),
                ],
              ),
            ).animate().fadeIn().moveX(begin: 20, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildIndividualTests(TestRepository testRepo) {
    return FutureBuilder<List<TestModel>>(
        future: testRepo.getPopularTests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final tests =
              snapshot.data!.where((t) => t.category != 'Package').toList();

          return SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GlassCard(
                    width: 160,
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .addTest(test);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Added ${test.name}"),
                          backgroundColor: VitalColors.oceanTeal,
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: VitalColors.electricBlue
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(LucideIcons.microscope,
                              color: VitalColors.electricBlue, size: 20),
                        ),
                        const Spacer(),
                        Text(test.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("PKR ${test.price.toInt()}",
                            style: const TextStyle(
                                color: VitalColors.oceanTeal,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(),
                );
              },
            ),
          );
        });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("View All",
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    ).animate().fadeIn();
  }
}
