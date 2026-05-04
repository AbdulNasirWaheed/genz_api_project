import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'courses_screen.dart';
import 'my_enrollments_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String userName;
  const DashboardScreen({super.key, required this.userId, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;
  List<dynamic> categories = [];
  bool isLoading = true;
  int _currentIndex = 0;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var dashResult = await ApiService.getDashboard();
    var catResult = await ApiService.getCategories();

    if (mounted) {
      setState(() {
        stats = dashResult['stats'] ?? dashResult['data'] ?? dashResult;
        categories = catResult['data'] ?? catResult['categories'] ?? catResult['results'] ?? [];
        isLoading = false;
      });
    }
  }

  String getStat(String key) {
    if (stats == null) return '0';
    switch (key) {
      case 'courses': return (stats!['total_courses'] ?? stats!['courses'] ?? 0).toString();
      case 'students': return (stats!['total_students'] ?? stats!['students'] ?? 0).toString();
      case 'enrollments': return (stats!['total_enrollments'] ?? stats!['enrollments'] ?? 0).toString();
      case 'bootcamps':
        if (stats!['by_type'] != null && stats!['by_type'] is Map) {
          return (stats!['by_type']['bootcamps'] ?? 0).toString();
        }
        return '0';
      case 'active': return (stats!['active_courses'] ?? stats!['active'] ?? 0).toString();
      case 'upcoming': return (stats!['upcoming_courses'] ?? stats!['upcoming'] ?? 0).toString();
    }
    return '0';
  }

  IconData getCategoryIcon(String category) {
    String name = category.toLowerCase();
    if (name.contains('web')) return Icons.code_rounded;
    if (name.contains('mobile') || name.contains('app')) return Icons.phone_android_rounded;
    if (name.contains('data') || name.contains('science')) return Icons.analytics_rounded;
    if (name.contains('cyber') || name.contains('security')) return Icons.security_rounded;
    if (name.contains('cloud')) return Icons.cloud_done_rounded;
    if (name.contains('ui') || name.contains('ux') || name.contains('design')) return Icons.draw_rounded;
    if (name.contains('digital') || name.contains('marketing')) return Icons.campaign_rounded;
    if (name.contains('competition')) return Icons.emoji_events_rounded;
    if (name.contains('bootcamp')) return Icons.terminal_rounded;
    if (name.contains('ai') || name.contains('intelligence')) return Icons.psychology_rounded;
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      _buildHome(),
      CoursesScreen(userId: widget.userId, initialCategory: _selectedCategory),
      MyEnrollmentsScreen(
        userId: widget.userId,
        onExplore: () => setState(() {
          _selectedCategory = 'all';
          _currentIndex = 1;
        }),
      ),
      ProfileScreen(userId: widget.userId, userName: widget.userName),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            setState(() {
              if (index == 1 && _currentIndex != 1) _selectedCategory = 'all';
              _currentIndex = index;
              if (index == 0) loadData();
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), activeIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), activeIcon: Icon(Icons.explore_rounded), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), activeIcon: Icon(Icons.auto_stories_rounded), label: 'My Learning'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: loadData,
        displacement: 40,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hello, ${widget.userName}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text('PREMIUM LEARNER', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withBlue(220)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative background elements
                      Positioned(right: -30, top: -20, child: Icon(Icons.blur_on_rounded, size: 200, color: Colors.white.withOpacity(0.05))),
                      Positioned(left: -20, top: 40, child: Icon(Icons.rocket_launch_rounded, size: 100, color: Colors.white.withOpacity(0.08))),
                      
                      // Brand Logo in header
                      Positioned(
                        top: 50,
                        left: 24,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.auto_stories_rounded, color: theme.colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'GenZ Learning',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLearningOverview(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Top Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            TextButton(onPressed: () => setState(() => _currentIndex = 1), child: Text('See All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryList(),
                        const SizedBox(height: 32),
                        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
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
    );
  }

  Widget _buildLearningOverview() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _overviewItem('Courses', getStat('courses'), Icons.auto_stories_rounded, theme.colorScheme.primary),
                _verticalDivider(),
                _overviewItem('Active', getStat('active'), Icons.bolt_rounded, const Color(0xFFF59E0B)),
                _verticalDivider(),
                _overviewItem('Students', getStat('students'), Icons.groups_2_rounded, const Color(0xFF10B981)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallStatItem('Enrollments', getStat('enrollments'), Icons.how_to_reg_rounded),
                _smallStatItem('Programs', getStat('bootcamps'), Icons.workspace_premium_rounded),
                _smallStatItem('New', getStat('upcoming'), Icons.upcoming_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(width: 1, height: 40, color: const Color(0xFFF1F5F9));

  Widget _overviewItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _smallStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text('$value $label', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildCategoryList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          String name = cat['name']?.toString() ?? cat['category']?.toString() ?? cat.toString();
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () { setState(() { _selectedCategory = name; _currentIndex = 1; }); },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Container(
                    height: 70, width: 70,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Icon(getCategoryIcon(name), color: Theme.of(context).colorScheme.primary, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF334155)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: _actionCard('Explore Catalog', 'Discover new skills', Icons.search_rounded, theme.colorScheme.primary, () => setState(() { _selectedCategory = 'all'; _currentIndex = 1; }))),
        const SizedBox(width: 16),
        Expanded(child: _actionCard('My Learning', 'Track your growth', Icons.auto_stories_rounded, const Color(0xFFF59E0B), () => setState(() => _currentIndex = 2))),
      ],
    );
  }

  Widget _actionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    bool isSec = color == const Color(0xFFF59E0B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: isSec ? const Color(0xFF78350F) : Colors.white, size: 20)),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: isSec ? const Color(0xFF78350F) : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: (isSec ? const Color(0xFF78350F) : Colors.white).withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
