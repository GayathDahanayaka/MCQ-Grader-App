import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcq_grader/src/widgets/gradient_background.dart';
import 'package:mcq_grader/src/widgets/glass_card.dart';
import 'package:mcq_grader/src/widgets/modern_button.dart';
import 'package:mcq_grader/src/services/api_service.dart';
import 'package:mcq_grader/src/screens/results_screen.dart';
class GradingScreen extends StatefulWidget {
  const GradingScreen({super.key});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  final ApiService _api = ApiService();
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _masterData;
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _mediumController = TextEditingController();

  // If uploading master key
  final _subjectController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _examDateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    final data = await _api.getMasterMetadata();
    if (data['success'] != false) {
       setState(() {
         _masterData = data;
       });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
      maxHeight: 3000,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _uploadMasterKey() async {
    if (_selectedImage == null) return;
    
    // Validate inputs
    if (_subjectController.text.isEmpty || _gradeLevelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all master key details")));
      return;
    }

    setState(() => _isLoading = true);

    final result = await _api.uploadMasterKey(
      _selectedImage!, 
      _subjectController.text, 
      _gradeLevelController.text, 
      _examDateController.text
    );

    setState(() => _isLoading = false);

    if (result['success'] != false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Master Key Set Successfully!")));
      _fetchMasterData();
      _clearImage(); // Reset for next action
      Navigator.pop(context); // Close dialog if open, though we might design this differently
    } else {
      _showError(result['error']);
    }
  }

  Future<void> _gradeStudent() async {
    if (_selectedImage == null) return;
    if (_studentNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Name is required")));
        return;
    }

    setState(() => _isLoading = true);

    final result = await _api.gradeStudent(
      _selectedImage!,
      _studentIdController.text,
      _studentNameController.text,
      _mediumController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] != false) {
      // Navigate to results
      if (!mounted) return;
      
      // Parse result data for the next screen
       var gradeData = {
        'score': result['total_score'],
        'total': result['out_of'],
        'correct': result['correct'],
        'wrong': result['wrong'],
        'unanswered': result['unanswered'],
        'percentage': result['percentage'],
        'details': result['details'],
        'student_info': result['student_info'],
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(resultData: gradeData),
        ),
      );
    } else {
      _showError(result['error']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isMasterRecored = _masterData != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text("Grading Station", style: GoogleFonts.outfit(color: Colors.white)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Master Key Status
                if (isMasterRecored)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.key, color: Colors.greenAccent),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Active Master Key", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                            Text(
                              "${_masterData!['subject']} (${_masterData!['grade_level']})",
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),

                // Image Selection Area
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 2),
                      image: _selectedImage != null 
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _selectedImage == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white54),
                            const SizedBox(height: 16),
                            Text("Tap to capture sheet", style: GoogleFonts.inter(color: Colors.white70)),
                            TextButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Or choose from gallery"),
                            )
                          ],
                        )
                      : Stack(
                          children: [
                             Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_selectedImage != null)
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                         TabBar(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          tabs: const [
                            Tab(text: "Grade Student"),
                            Tab(text: "Set Master Key"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 400, // Fixed height for form area
                          child: TabBarView(
                            children: [
                              // Grade Student Tab
                              GlassCard(
                                child: Column(
                                  children: [
                                    if (!isMasterRecored) 
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                        child: const Text("⚠️ No Master Key set! Please set one first.", style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    TextField(
                                      controller: _studentNameController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Student Name",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _studentIdController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Student ID (Optional)",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.badge, color: Colors.white70),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _mediumController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Medium (Optional)",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.language, color: Colors.white70),
                                      ),
                                    ),
                                    const Spacer(),
                                    ModernButton(
                                      label: "Grade Now",
                                      icon: Icons.check_circle,
                                      isLoading: _isLoading,
                                      onPressed: isMasterRecored ? _gradeStudent : () {}, // Disable if no master key
                                      color: isMasterRecored ? null : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),

                              // Set Master Key Tab
                              GlassCard(
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _subjectController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Subject Name",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.book, color: Colors.white70),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _gradeLevelController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Grade Level",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.school, color: Colors.white70),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _examDateController,
                                      readOnly: true, // Make date picker clickable
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000), 
                                            lastDate: DateTime(2101)
                                        );
                                        if (pickedDate != null) {
                                          _examDateController.text = pickedDate.toString().split(' ')[0];
                                        }
                                      },
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: "Exam Date",
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.calendar_today, color: Colors.white70),
                                      ),
                                    ),
                                    const Spacer(),
                                    ModernButton(
                                      label: "Upload Master Key",
                                      icon: Icons.upload_file,
                                      isLoading: _isLoading,
                                      color: Colors.green,
                                      onPressed: _uploadMasterKey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

