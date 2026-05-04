import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  final int userId;
  final String? initialCategory;
  const CoursesScreen({super.key, required this.userId, this.initialCategory});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> courses = [];
  List<dynamic> _filtered = [];
  List<dynamic> categories = [];
  bool isLoading = true;

  String selectedType = 'all';
  late String selectedCategory;
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'all';
    _initData();
  }

  @override
  void didUpdateWidget(covariant CoursesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory && widget.initialCategory != null) {
      setState(() {
        selectedCategory = widget.initialCategory!;
      });
      loadCourses();
    }
  }

  Future<void> _initData() async {
    await Future.wait([
      loadCourses(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadCategories() async {
    var result = await ApiService.getCategories();
    if (mounted) {
      setState(() {
        categories = result['data'] ?? result['categories'] ?? result['results'] ?? [];
      });
    }
  }

  Future<void> loadCourses() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    var result = await ApiService.getCourses(
      type: selectedType == 'all' ? null : selectedType,
      category: selectedCategory == 'all' ? null : selectedCategory,
    );

    if (!mounted) return;
    setState(() {
      courses = result['courses'] ?? result['data'] ?? result['results'] ?? [];
      _applySearch();
      isLoading = false;
    });
  }

  void _applySearch() {
    final q = searchQuery.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(courses)
        : courses.where((c) {
      final title = (c['title'] ?? '').toString().toLowerCase();
      final cat   = (c['category'] ?? '').toString().toLowerCase();
      final inst  = (c['instructor'] ?? '').toString().toLowerCase();
      return title.contains(q) || cat.contains(q) || inst.contains(q);
    }).toList();
  }

  Color typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'bootcamp':    return Colors.purple;
      case 'competition': return Colors.deepOrange;
      default:            return const Color(0xFF1565C0);
    }
  }

  Color statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'ongoing':   return Colors.green;
      case 'upcoming':  return Colors.orange;
      case 'completed': return Colors.grey;
      default:          return Colors.blueGrey;
    }
  }

  IconData typeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'bootcamp':    return Icons.laptop_mac_rounded;
      case 'competition': return Icons.emoji_events_rounded;
      default:            return Icons.school_rounded;
    }
  }

  String formatFee(dynamic fee) {
    final d = double.tryParse(fee?.toString() ?? '');
    if (d == null) return '—';
    return 'PKR ${d.toStringAsFixed(0)}';
  }

  int seatsAvailable(dynamic course) {
    return int.tryParse(
      course['seats_available']?.toString() ??
          ((int.tryParse(course['seats']?.toString() ?? '0') ?? 0) -
              (int.tryParse(course['enrolled']?.toString() ?? '0') ?? 0)).toString(),
    ) ?? 0;
  }

  Widget _chip(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: TextStyle(fontSize: 12, color: color ?? Colors.grey[700]), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    final String type = course['type']?.toString() ?? 'course';
    final String? status = course['status']?.toString();
    final int avail = seatsAvailable(course);
    final bool full = avail <= 0;
    final Color tColor = typeColor(type);
    final Color sColor = statusColor(status);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(
              courseId: int.parse(course['id'].toString()),
              userId: widget.userId,
            ),
          ),
        );
        loadCourses();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(typeIcon(type), color: tColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title']?.toString() ?? 'Untitled Course',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _chip(type.toUpperCase(), tColor),
                                  if (status != null) _chip(status.toUpperCase(), sColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _infoItem(Icons.person_rounded, course['instructor']?.toString() ?? 'Expert Instructor')),
                        Expanded(child: _infoItem(Icons.category_rounded, course['category']?.toString() ?? 'General')),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Course Fee',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              formatFee(course['fee']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: full ? const Color(0xFFFEF2F2) : const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: full ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE)),
                          ),
                          child: Text(
                            full ? 'CLASS FULL' : '$avail SEATS LEFT',
                            style: TextStyle(
                              color: full ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterBar() {
    List<Map<String, dynamic>> catItems = [
      {'key': 'all', 'label': 'All Fields', 'icon': Icons.category_rounded},
    ];
    
    for (var cat in categories) {
      String name = cat['name']?.toString() ?? cat['category']?.toString() ?? cat.toString();
      catItems.add({
        'key': name,
        'label': name,
        'icon': Icons.label_important_rounded,
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _filterRow([
            {'key': 'all', 'label': 'All Programs', 'icon': Icons.grid_view_rounded},
            {'key': 'course', 'label': 'Courses', 'icon': Icons.school_rounded},
            {'key': 'bootcamp', 'label': 'Bootcamps', 'icon': Icons.terminal_rounded},
          ], selectedType, (v) { setState(() => selectedType = v); loadCourses(); }),
          _filterRow(catItems, selectedCategory, (v) { setState(() => selectedCategory = v); loadCourses(); }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _filterRow(List<Map<String, dynamic>> items, String current, Function(String) onSelect) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: items.map((i) {
          bool sel = current == i['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(i['label']),
              avatar: Icon(i['icon'], size: 16, color: sel ? Colors.white : theme.colorScheme.primary),
              selected: sel,
              onSelected: (bool selected) => onSelect(i['key']),
              backgroundColor: Colors.white,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: sel ? Colors.white : theme.colorScheme.primary,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: StadiumBorder(side: BorderSide(color: sel ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.2))),
              elevation: 0,
              pressElevation: 0,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Available Programs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadCourses,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() {
                  searchQuery = v;
                  _applySearch();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search courses, instructors...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            searchQuery = '';
                            _applySearch();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No programs found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filtered.length,
              itemBuilder: (context, index) => Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _courseCard(_filtered[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}