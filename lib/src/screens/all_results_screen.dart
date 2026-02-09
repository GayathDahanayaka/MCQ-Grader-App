import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcq_grader/src/widgets/gradient_background.dart';
import 'package:mcq_grader/src/widgets/glass_card.dart';

class AllResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic>? availableFilters;
  final Function({String? subject, String? gradeLevel, String? grade}) onExport;

  const AllResultsScreen({
    super.key,
    required this.results,
    this.availableFilters,
    required this.onExport,
  });

  @override
  State<AllResultsScreen> createState() => _AllResultsScreenState();
}

class _AllResultsScreenState extends State<AllResultsScreen> {
  String? _selectedSubject;
  String? _selectedGradeLevel;
  String? _selectedGrade;

  List<Map<String, dynamic>> get _filteredResults {
    var filtered = widget.results;
    if (_selectedSubject != null) {
      filtered = filtered.where((r) => r['subject'] == _selectedSubject).toList();
    }
    if (_selectedGradeLevel != null) {
      filtered = filtered.where((r) => r['grade_level'] == _selectedGradeLevel).toList();
    }
    if (_selectedGrade != null) {
      filtered = filtered.where((r) => r['grade'] == _selectedGrade).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Grading History', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () => widget.onExport(
               subject: _selectedSubject,
               gradeLevel: _selectedGradeLevel,
               grade: _selectedGrade,
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Filters
              if (widget.availableFilters != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      if (widget.availableFilters!['subjects'] != null)
                        _buildFilterChip("Subject", _selectedSubject, widget.availableFilters!['subjects'], (val) => setState(() => _selectedSubject = val)),
                      const SizedBox(width: 8),
                      if (widget.availableFilters!['grade_levels'] != null)
                       _buildFilterChip("Level", _selectedGradeLevel, widget.availableFilters!['grade_levels'], (val) => setState(() => _selectedGradeLevel = val)),
                      const SizedBox(width: 8),
                      if (widget.availableFilters!['grades'] != null)
                        _buildFilterChip("Grade", _selectedGrade, widget.availableFilters!['grades'], (val) => setState(() => _selectedGrade = val)),
                        
                      if (_selectedSubject != null || _selectedGradeLevel != null || _selectedGrade != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () => setState(() {
                              _selectedSubject = null;
                              _selectedGradeLevel = null;
                              _selectedGrade = null;
                            }),
                          ),
                        )
                    ],
                  ),
                ),

              Expanded(
                child: results.isEmpty 
                ? Center(child: Text("No results found", style: GoogleFonts.inter(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _getColorForGrade(result['grade']).withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _getColorForGrade(result['grade'])),
                              ),
                              child: Text(
                                result['grade'],
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: _getColorForGrade(result['grade']),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['name'] ?? 'Unknown',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    "${result['subject']} • ${result['exam_date']}",
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${result['percentage']}%",
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  "${result['score']} / ${result['total_questions']}",
                                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selectedValue, List<dynamic> options, Function(String?) onSelected) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF1E293B),
          textStyle: GoogleFonts.inter(color: Colors.white),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        itemBuilder: (context) => options.map((opt) => PopupMenuItem(
          value: opt.toString(),
          child: Text(opt.toString(), style: GoogleFonts.inter(color: Colors.white)),
        )).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selectedValue != null ? Colors.white : Colors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Text(
                selectedValue ?? label,
                style: GoogleFonts.inter(
                  color: selectedValue != null ? Colors.black : Colors.white,
                  fontWeight: selectedValue != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down, 
                color: selectedValue != null ? Colors.black : Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForGrade(String grade) {
    switch (grade) {
      case 'A+':
      case 'A': return Colors.green;
      case 'B+':
      case 'B': return Colors.blue;
      case 'C+':
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'S': return Colors.deepOrange;
      default: return Colors.red;
    }
  }
}
