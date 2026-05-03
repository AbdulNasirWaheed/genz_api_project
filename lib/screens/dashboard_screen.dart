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
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() async {
    var result = await ApiService.getDashboard();
    print('📊 DASHBOARD: $result');
    setState(() {
      stats = result;
      isLoading = false;
    });
  }

  Widget statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      CoursesScreen(userId: widget.userId),
      MyEnrollmentsScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId, userName: widget.userName),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Enrollments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}! 👋'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Institute Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Stats Cards Row 1
            Row(
              children: [
                statCard(
                  'Total Courses',
                  stats?['total_courses']?.toString() ?? '0',
                  Icons.book,
                  Colors.blue,
                ),
                statCard(
                  'Total Students',
                  stats?['total_students']?.toString() ?? '0',
                  Icons.people,
                  Colors.green,
                ),
              ],
            ),

            Row(
              children: [
                statCard(
                  'Enrollments',
                  stats?['total_enrollments']?.toString() ?? '0',
                  Icons.assignment_turned_in,
                  Colors.orange,
                ),
                statCard(
                  'Bootcamps',
                  stats?['total_bootcamps']?.toString() ?? '0',
                  Icons.laptop,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('🚀 Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    'Browse Courses',
                    Icons.school,
                    Colors.blue,
                        () => setState(() => _currentIndex = 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickAction(
                    'My Enrollments',
                    Icons.list_alt,
                    Colors.green,
                        () => setState(() => _currentIndex = 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}