import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final int userId;
  const CourseDetailScreen({super.key, required this.courseId, required this.userId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Map<String, dynamic>? course;
  bool isLoading = true;
  bool isEnrolling = false;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  void loadDetails() async {
    var result = await ApiService.getCourseDetails(widget.courseId);
    print('📖 COURSE DETAIL: $result');
    setState(() {
      course = result['data'] ?? result['course'] ?? result;
      isLoading = false;
    });
  }

  void enroll() async {
    setState(() => isEnrolling = true);
    var result = await ApiService.enroll(
      userId: widget.userId,
      courseId: widget.courseId,
    );
    setState(() => isEnrolling = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result['success'] == true ? '🎉 Enrolled!' : '❌ Oops!'),
        content: Text(result['message'] ?? 'Something happened'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Course Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : course == null
          ? const Center(child: Text('Failed to load details'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    course!['title']?.toString() ?? course!['name']?.toString() ?? 'Course',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Course Info',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  if (course!['description'] != null)
                    detailRow('Description', course!['description'].toString()),
                  if (course!['type'] != null)
                    detailRow('Type', course!['type'].toString()),
                  if (course!['status'] != null)
                    detailRow('Status', course!['status'].toString()),
                  if (course!['category'] != null)
                    detailRow('Category', course!['category'].toString()),
                  if (course!['duration'] != null)
                    detailRow('Duration', course!['duration'].toString()),
                  if (course!['start_date'] != null)
                    detailRow('Start Date', course!['start_date'].toString()),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_reg, color: Colors.white),
                label: isEnrolling
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enroll Now',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isEnrolling ? null : enroll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}