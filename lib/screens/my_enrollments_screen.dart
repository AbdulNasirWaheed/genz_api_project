import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_detail_screen.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onExplore;
  const MyEnrollmentsScreen({super.key, required this.userId, this.onExplore});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  List<dynamic> enrollments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEnrollments();
  }

  Future<void> loadEnrollments() async {
    setState(() => isLoading = true);
    var result = await ApiService.getMyEnrollments(widget.userId);
    if (mounted) {
      setState(() {
        enrollments = result['data'] ?? result['enrollments'] ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Learning Journey', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadEnrollments,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : enrollments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadEnrollments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: enrollments.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: _enrollmentCard(enrollments[index]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_rounded, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              "Start Your Journey",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't enrolled in any programs yet. Explore our catalog to find your next skill.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Explore Programs"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enrollmentCard(Map<String, dynamic> e) {
    final theme = Theme.of(context);
    String title = e['title']?.toString() ?? e['course_name']?.toString() ?? 'Untitled Program';
    String status = (e['status']?.toString() ?? 'Active').toUpperCase();
    String date = e['enrolled_at']?.toString() ?? e['created_at']?.toString() ?? 'Recent';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        onTap: () {
           if (e['course_id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(
                    courseId: int.parse(e['course_id'].toString()),
                    userId: widget.userId,
                  ),
                ),
              );
           }
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
