import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  final int userId;
  const CoursesScreen({super.key, required this.userId});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> courses = [];
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  void loadCourses({String? type}) async {
    setState(() => isLoading = true);
    var result = await ApiService.getCourses(type: type == 'all' ? null : type);
    print('📚 COURSES: $result');
    setState(() {
      courses = result['data'] ?? result['courses'] ?? [];
      isLoading = false;
    });
  }

  Color typeColor(String? type) {
    switch (type) {
      case 'bootcamp': return Colors.purple;
      case 'competition': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Courses'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ['all', 'course', 'bootcamp', 'competition'].map((f) {
                bool isSelected = selectedFilter == f;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedFilter = f);
                    loadCourses(type: f);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      f[0].toUpperCase() + f.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Courses List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : courses.isEmpty
                ? const Center(child: Text('No courses found'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];
                String type = course['type']?.toString() ?? 'course';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(
                          courseId: int.parse(course['id'].toString()),
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                            color: typeColor(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.school, color: typeColor(type)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title']?.toString() ?? course['name']?.toString() ?? 'Course',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeColor(type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                      color: typeColor(type),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}