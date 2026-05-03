import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  final int userId;
  const MyEnrollmentsScreen({super.key, required this.userId});

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

  void loadEnrollments() async {
    var result = await ApiService.getMyEnrollments(widget.userId);
    print('📋 ENROLLMENTS: $result');
    setState(() {
      enrollments = result['data'] ?? result['enrollments'] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Enrollments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : enrollments.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 80, color: Colors.grey),
            const SizedBox(height: 12),
            const Text("You haven't enrolled in anything yet!",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Go to Courses and enroll 👍',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enrollments.length,
        itemBuilder: (context, index) {
          var e = enrollments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 4)
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title']?.toString() ?? e['course_name']?.toString() ?? 'Course',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (e['enrolled_at'] != null || e['created_at'] != null)
                        Text(
                          'Enrolled: ${e['enrolled_at']?.toString() ?? e['created_at']?.toString() ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}