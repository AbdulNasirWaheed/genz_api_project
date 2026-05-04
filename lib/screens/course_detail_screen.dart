import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final int userId;
  const CourseDetailScreen(
      {super.key, required this.courseId, required this.userId});

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

  Future<void> loadDetails() async {
    var result = await ApiService.getCourseDetails(widget.courseId);
    print('📖 COURSE DETAIL: $result');
    setState(() {
      // ✅ API returns {"success":true,"course":{...}} — extract "course"
      course = result['course'] ?? result['data'] ?? result;
      isLoading = false;
    });
  }

  void enroll() async {
    setState(() => isEnrolling = true);
    var result = await ApiService.enroll(
      userId: widget.userId,
      courseId: widget.courseId,
    );
    
    if (result['success'] == true) {
      await loadDetails(); // Refresh UI "on the spot"
    }

    setState(() => isEnrolling = false);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result['success'] == true ? '🎉 Enrolled!' : '❌ Oops!'),
        content: Text(result['message'] ?? 'Something happened'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'))
        ],
      ),
    );
  }

  Widget detailRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Helper: badge chip ────────────────────────────────────────────
  Widget _badge(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':   return Colors.green;
      case 'upcoming': return Colors.orange;
      case 'closed':   return Colors.red;
      default:         return Colors.grey;
    }
  }

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'bootcamp':    return Colors.purple;
      case 'competition': return Colors.red;
      default:            return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Seat availability helpers
    final int seats = int.tryParse(course?['seats']?.toString() ?? '0') ?? 0;
    final int enrolled =
        int.tryParse(course?['total_enrolled']?.toString() ??
            course?['enrolled']?.toString() ?? '0') ??
            0;
    final int available =
        int.tryParse(course?['seats_available']?.toString() ?? '-1') ??
            (seats - enrolled);
    final double fillRatio = seats > 0 ? (enrolled / seats).clamp(0.0, 1.0) : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : course == null
          ? const Center(child: Text('Failed to load details'))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withBlue(150)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, size: 80, color: Colors.white),
                  ),
                ),
              ),
            ),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (course!['type'] != null)
                          _badge(
                              course!['type'].toString().toUpperCase(),
                              _typeColor(course!['type']?.toString())),
                        const SizedBox(width: 8),
                        if (course!['status'] != null)
                          _badge(
                              course!['status'].toString().toUpperCase(),
                              _statusColor(course!['status']?.toString())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course!['title']?.toString() ?? 'Course Details',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'by ${course!['instructor'] ?? 'Expert Instructor'}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),

                    if (course!['description'] != null) ...[
                      const Text('About this Course',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        course!['description'].toString(),
                        style: TextStyle(color: Colors.grey.shade800, height: 1.6, fontSize: 15),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const Text('Course Information',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _detailItem(Icons.category_rounded, 'Category', course!['category']?.toString() ?? 'General'),
                          _detailItem(Icons.timer_rounded, 'Duration', course!['duration']?.toString() ?? 'Not specified'),
                          _detailItem(Icons.calendar_today_rounded, 'Start Date', course!['start_date']?.toString() ?? 'TBD'),
                          _detailItem(Icons.payments_rounded, 'Enrollment Fee',
                              'PKR ${double.tryParse(course!['fee']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}', 
                              isLast: true, valueColor: Colors.green.shade700),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text('Availability',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statBox('Total Seats', seats.toString(), theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        _statBox('Enrolled', enrolled.toString(), Colors.orange),
                        const SizedBox(width: 12),
                        _statBox('Available', available.toString(), available > 0 ? Colors.green : Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fillRatio,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          fillRatio >= 0.9 ? Colors.red : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${(fillRatio * 100).toStringAsFixed(0)}% of seats are filled',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isEnrolling || available <= 0) ? null : enroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isEnrolling
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      available > 0 ? 'Enroll in Program' : 'Program Full',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value, {bool isLast = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _seatStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}