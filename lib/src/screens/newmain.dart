import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

void main() {
  runApp(const EnhancedOMRApp());
}

class EnhancedOMRApp extends StatelessWidget {
  const EnhancedOMRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanced OMR Grader Pro v3.0',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A2342), // Deep Navy Blue
        scaffoldBackgroundColor: const Color(0xFF0A2342),
        cardColor: const Color(0xFF1E3A5F), // Cool Grey
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), // Emerald Green
          secondary: Color(0xFF1E3A5F), // Cool Grey
          surface: Color(0xFF1E3A5F), // Cool Grey
          background: Color(0xFF0A2342), // Deep Navy Blue
          error: Color(0xFFEF4444),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981), // Emerald Green
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 4,
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

// Onboarding Screens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2342),
                  Color(0xFF1E3A5F),
                ],
              ),
            ),
          ),
          
          // Content
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildOnboardingPage(
                title: "Welcome to OMR Grader Pro",
                subtitle: "Smart Grading Made Simple",
                description: "Experience the future of OMR sheet grading with our advanced AI-powered technology.",
                illustration: _buildIllustration1(),
              ),
              _buildOnboardingPage(
                title: "Snap & Grade Instantly",
                subtitle: "Lightning Fast Processing",
                description: "Capture OMR sheets with your camera and get instant results with our advanced detection algorithms.",
                illustration: _buildIllustration2(),
              ),
              _buildOnboardingPage(
                title: "Track Progress & Insights",
                subtitle: "Comprehensive Analytics",
                description: "Manage master keys, track student performance, and export detailed reports with ease.",
                illustration: _buildIllustration3(),
                isLastPage: true,
              ),
            ],
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF10B981) // Emerald Green
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Get Started button
                if (_currentPage == 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Emerald Green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shadowColor: const Color(0xFF10B981).withOpacity(0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String subtitle,
    required String description,
    required Widget illustration,
    bool isLastPage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Expanded(
            flex: 3,
            child: illustration,
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981), // Emerald Green
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration1() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.2),
                const Color(0xFF10B981).withOpacity(0.05),
              ],
            ),
          ),
        ),
        
        // App logo
        _buildAppLogo(size: 120),
      ],
    );
  }

  Widget _buildIllustration2() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Phone mockup
        Container(
          width: 200,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Phone status bar
              Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
              
              // Phone screen
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2342),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Scanning lines
                      SizedBox(
                        width: 150,
                        height: 100,
                        child: Stack(
                          children: [
                            // OMR sheet
                            Container(
                              width: 150,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            
                            // Scanning line
                            AnimatedPositioned(
                              duration: const Duration(seconds: 2),
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF10B981),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Scanning effect
        TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (value * 0.2),
              child: Opacity(
                opacity: 1 - value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIllustration3() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Chart background
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        // Bar chart
        SizedBox(
          width: 200,
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              5,
              (index) {
                final heights = [0.4, 0.7, 0.5, 0.9, 0.6];
                final height = heights[index];
                
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 800 + (index * 200)),
                  tween: Tween<double>(begin: 0, end: height),
                  builder: (context, value, child) {
                    return Container(
                      width: 30,
                      height: 200 * value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF10B981),
                            const Color(0xFF10B981).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppLogo({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10B981), // Emerald Green
            Color(0xFF059669), // Darker Emerald
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}

// Home Screen with Modern UI
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  String _statusMessage = "Welcome! Enhanced OMR Grader Pro v3.0 🎓";
  Map<String, dynamic>? _studentInfo;
  Map<String, dynamic>? _gradeResults;
  Map<String, dynamic>? _masterMetadata;
  bool _isLoading = false;
  bool _masterKeySet = false;
  bool _serverOnline = false;
  
  // Student input controllers
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _mediumController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  // IMPORTANT: Update this IP address
  final String _baseUrl = 'http://192.168.8.127:5000';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _checkServerConnection();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _mediumController.dispose();
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/test')).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _serverOnline = true;
          _statusMessage = "✅ Server Online!\n\n"
              "${data['message']}\n\n"
              "Version: ${data['version']}\n"
              "Ready to grade!";
        });
        _animationController.forward();
        
        // Check if master key is set
        _checkMasterKey();
      }
    } catch (e) {
      setState(() {
        _serverOnline = false;
        _statusMessage = "⚠️ Cannot connect to server.\n\n"
            "Please ensure:\n"
            "1. Python server is running (python enhanced_backend.py)\n"
            "2. IP address is correct: $_baseUrl\n"
            "3. Both devices on same WiFi\n\n"
            "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _checkMasterKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_master_metadata'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _masterKeySet = true;
            _masterMetadata = {
              'subject': data['subject'],
              'grade_level': data['grade_level'],
              'exam_date': data['exam_date'],
            };
            _statusMessage = "✅ Master Key Active!\n\n"
                "Subject: ${data['subject']}\n"
                "Grade: ${data['grade_level']}\n"
                "Date: ${data['exam_date']}\n\n"
                "🎯 Ready to grade students!";
          });
        }
      }
    } catch (e) {
      // Master key not set yet
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 3000,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _statusMessage = "✓ Image selected! Choose an action below.";
          _gradeResults = null;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      _showErrorDialog("Error selecting image", e.toString());
    }
  }

  Future<void> _uploadMasterKey() async {
    if (_selectedImage == null) {
      _showErrorDialog("No Image", "Please select an image first!");
      return;
    }

    // Show dialog to get master key details
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _MasterKeyDialog(),
    );

    if (result == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "📝 Processing master answer key...\nPlease wait...";
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload_master'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
      
      request.fields['subject'] = result['subject'] ?? '';
      request.fields['exam_date'] = result['exam_date'] ?? '';
      request.fields['grade_level'] = result['grade_level'] ?? 'General';

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        setState(() {
          _masterKeySet = true;
          _masterMetadata = {
            'subject': data['subject'],
            'grade_level': data['grade_level'],
            'exam_date': data['exam_date'],
          };
          _statusMessage = "✅ Master Key Set Successfully!\n\n"
              "Subject: ${data['subject']}\n"
              "Grade Level: ${data['grade_level']}\n"
              "Exam Date: ${data['exam_date']}\n"
              "Answers detected: ${data['valid_answers']}/40\n\n"
              "🎯 Ready to grade students!\n"
              "Subject will auto-fill for all students.";
          _gradeResults = null;
          _studentInfo = null;
        });
        
        _animationController.forward(from: 0);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Master key uploaded - ${data['subject']}'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        var errorData = json.decode(response.body);
        _showErrorDialog("Upload Failed", errorData['error'] ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorDialog("Connection Error", 
        "Failed to connect to server.\n\n"
        "Error: ${e.toString()}\n\n"
        "Please check server connection.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _gradeStudent() async {
    if (_selectedImage == null) {
      _showErrorDialog("No Image", "Please select an image first!");
      return;
    }

    if (!_masterKeySet || _masterMetadata == null) {
      _showErrorDialog("No Master Key", 
        "Please set master key first!\n\n"
        "The master key defines the subject and correct answers.");
      return;
    }

    // Show student info dialog (subject auto-filled from master)
    final shouldContinue = await _showStudentInfoDialog();
    if (!shouldContinue) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "📊 Grading student sheet...\n"
          "Subject: ${_masterMetadata!['subject']}\n"
          "Processing image...";
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/grade_student'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
      
      // Add student information (subject comes from master key)
      request.fields['student_id'] = _studentIdController.text.trim();
      request.fields['student_name'] = _studentNameController.text.trim();
      request.fields['student_medium'] = _mediumController.text.trim();

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        setState(() {
          _statusMessage = "✅ Grading Complete!";
          _studentInfo = data['student_info'];
          _gradeResults = {
            'score': data['total_score'],
            'total': data['out_of'],
            'correct': data['correct'],
            'wrong': data['wrong'],
            'unanswered': data['unanswered'],
            'percentage': data['percentage'],
            'details': data['details'],
          };
        });
        
        _animationController.forward(from: 0);
        _showSuccessDialog();
        
        // Clear form for next student
        _clearStudentForm();
      } else {
        var errorData = json.decode(response.body);
        _showErrorDialog("Grading Failed", errorData['error'] ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorDialog("Connection Error", 
        "Failed to grade student.\n\n"
        "Error: ${e.toString()}\n\n"
        "Please check server connection.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showStudentInfoDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text(
              'Student Information',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show subject from master key
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subject (from master key)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _masterMetadata!['subject'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Show grade level from master key
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Grade Level (from master key)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _masterMetadata!['grade_level'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _studentIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Student ID (Optional)',
                  hintText: 'e.g., 2024001',
                  prefixIcon: Icon(Icons.badge, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF10B981)),
                  ),
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studentNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  hintText: 'Enter student name',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF10B981)),
                  ),
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mediumController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Medium (Optional)',
                  hintText: 'e.g., English, Sinhala, Tamil',
                  prefixIcon: Icon(Icons.language, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF10B981)),
                  ),
                  labelStyle: TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '* Required field\n'
                'Subject and grade auto-filled from master key\n'
                'System will auto-detect other fields if not provided',
                style: TextStyle(fontSize: 12, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF10B981))),
          ),
          ElevatedButton(
            onPressed: () {
              if (_studentNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Please enter student name'),
                    backgroundColor: Color(0xFF3B82F6),
                  ),
                );
                return;
              }
              Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _clearStudentForm() {
    _studentIdController.clear();
    _studentNameController.clear();
    _mediumController.clear();
  }

  Future<void> _exportToExcel({String? subject, String? gradeLevel, String? grade}) async {
    setState(() => _isLoading = true);
    
    try {
      var uri = Uri.parse('$_baseUrl/export_excel');
      var queryParams = <String, String>{};
      
      if (subject != null) queryParams['subject'] = subject;
      if (gradeLevel != null) queryParams['grade_level'] = gradeLevel;
      if (grade != null) queryParams['grade'] = grade;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        // Save file
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().toString().replaceAll(':', '-').split('.')[0];
        final filePath = '${directory.path}/grading_results_$timestamp.xlsx';
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Share file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'OMR Grading Results - ${DateTime.now().toString().split(' ')[0]}',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Excel exported!\n$filePath'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        _showErrorDialog('Export Failed', 'No results available matching the filters');
      }
    } catch (e) {
      _showErrorDialog('Export Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewAllResults() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_all_results'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        if (data['success']) {
          // Get filter options
          final filtersResponse = await http.get(
            Uri.parse('$_baseUrl/get_filters'),
          ).timeout(const Duration(seconds: 5));
          
          Map<String, dynamic>? availableFilters;
          if (filtersResponse.statusCode == 200) {
            var filtersData = json.decode(filtersResponse.body);
            if (filtersData['success']) {
              availableFilters = filtersData['filters'];
            }
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllResultsScreen(
                results: List<Map<String, dynamic>>.from(data['results']),
                availableFilters: availableFilters,
                onExport: _exportToExcel,
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('Error', 'Could not fetch results');
      }
    } catch (e) {
      _showErrorDialog('Connection Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    if (_gradeResults == null) return;
    
    final percentage = (_gradeResults!['percentage'] as num).toDouble();
    final score = _gradeResults!['score'];
    final total = _gradeResults!['total'];
    
    String grade;
    Color gradeColor;
    
    if (percentage >= 90) {
      grade = 'A+';
      gradeColor = const Color(0xFF10B981);
    } else if (percentage >= 80) {
      grade = 'A';
      gradeColor = const Color(0xFF10B981);
    } else if (percentage >= 70) {
      grade = 'B';
      gradeColor = const Color(0xFF3B82F6);
    } else if (percentage >= 60) {
      grade = 'C';
      gradeColor = const Color(0xFFF59E0B);
    } else if (percentage >= 50) {
      grade = 'D';
      gradeColor = const Color(0xFFEF4444);
    } else {
      grade = 'F';
      gradeColor = const Color(0xFFEF4444);
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: Row(
          children: [
            Icon(Icons.star, color: gradeColor, size: 32),
            const SizedBox(width: 10),
            const Text(
              'Grading Complete!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gradeColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      grade,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_studentInfo != null) ...[
                _buildInfoItem('Student ID', _studentInfo!['student_id'] ?? 'N/A'),
                _buildInfoItem('Name', _studentInfo!['name'] ?? 'Unknown'),
                _buildInfoItem('Subject', _studentInfo!['subject'] ?? 'Unknown'),
                _buildInfoItem('Grade Level', _studentInfo!['grade_level'] ?? 'Unknown'),
                _buildInfoItem('Medium', _studentInfo!['medium'] ?? 'Unknown'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF10B981))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDetailedResults();
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedResults() {
    if (_gradeResults == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedResultsScreen(
          details: _gradeResults!['details'],
          studentInfo: _studentInfo,
          score: _gradeResults!['score'],
          total: _gradeResults!['total'],
          percentage: (_gradeResults!['percentage'] as num).toDouble(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        title: Row(
          children: [
            // App Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF10B981), // Emerald Green
                    Color(0xFF059669), // Darker Emerald
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            const Text(
              "Enhanced OMR Grader Pro",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _serverOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _serverOnline ? const Color(0xFF10B981) : Colors.white70,
            ),
            onPressed: _checkServerConnection,
            tooltip: _serverOnline ? 'Server Online' : 'Server Offline',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'export') {
                _exportToExcel();
              } else if (value == 'results') {
                _viewAllResults();
              } else if (value == 'refresh') {
                _checkServerConnection();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.file_download, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    const Text(
                      'Export to Excel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'results',
                child: Row(
                  children: [
                    const Icon(Icons.list, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    const Text(
                      'View All Results',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    const Text(
                      'Refresh Connection',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A2342),
              Color(0xFF1E3A5F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusBanner(),
                const SizedBox(height: 16),
                _buildImageCard(),
                const SizedBox(height: 16),
                _buildImageSourceButtons(),
                const SizedBox(height: 24),
                
                if (_selectedImage != null) ...[
                  _buildMasterKeyButton(),
                  const SizedBox(height: 12),
                  _buildGradeStudentButton(),
                  const SizedBox(height: 24),
                ],
                
                if (_isLoading) _buildLoadingIndicator(),
                
                _buildStatusMessage(),
                
                if (_gradeResults != null) ...[
                  const SizedBox(height: 16),
                  _buildScoreCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    String bannerText = "";
    List<Color> bannerColors;
    IconData bannerIcon;
    
    if (_masterKeySet && _masterMetadata != null) {
      bannerText = "✅ Master key active\n${_masterMetadata!['subject']} - ${_masterMetadata!['grade_level']}";
      bannerColors = [const Color(0xFF10B981), const Color(0xFF059669)];
      bannerIcon = Icons.check_circle;
    } else if (_serverOnline) {
      bannerText = "Step 1: Upload master key";
      bannerColors = [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
      bannerIcon = Icons.info;
    } else {
      bannerText = "⚠️ Server offline";
      bannerColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
      bannerIcon = Icons.error_outline;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bannerColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bannerColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              bannerText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (_selectedImage == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 100,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No image selected",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap Camera or Gallery below",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  
                  // Scanning effect
                  if (_gradeResults != null)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: GlowPainter(
                              glowAnimation: _glowAnimation.value,
                              glowColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassButton(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
            icon: Icons.camera_alt,
            label: "Camera",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassButton(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
            icon: Icons.photo_library,
            label: "Gallery",
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: onPressed != null
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterKeyButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _uploadMasterKey,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.key, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  "SET MASTER KEY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeStudentButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _masterKeySet 
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6B7280), const Color(0xFF4B5563)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _masterKeySet ? [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_isLoading || !_masterKeySet) ? null : _gradeStudent,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grade,
                  color: _masterKeySet ? Colors.white : Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "GRADE STUDENT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _masterKeySet ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
          const SizedBox(height: 16),
          Text(
            "Processing...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage, 
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final percentage = (_gradeResults!['percentage'] as num).toDouble();
    Color scoreColor = percentage >= 75 ? const Color(0xFF10B981) : 
                       percentage >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Final Score",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${_gradeResults!['score']}/${_gradeResults!['total']}",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 24,
              color: scoreColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.check_circle,
                'Correct',
                _gradeResults!['correct'].toString(),
                const Color(0xFF10B981),
              ),
              _buildStatItem(
                Icons.cancel,
                'Wrong',
                _gradeResults!['wrong'].toString(),
                const Color(0xFFEF4444),
              ),
              _buildStatItem(
                Icons.help_outline,
                'Unanswered',
                _gradeResults!['unanswered'].toString(),
                const Color(0xFF6B7280),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showDetailedResults,
            icon: const Icon(Icons.list_alt),
            label: const Text("View Detailed Results"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// Custom painter for glow effect
class GlowPainter extends CustomPainter {
  final double glowAnimation;
  final Color glowColor;

  GlowPainter({
    required this.glowAnimation,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = glowColor.withOpacity(0.3 * glowAnimation)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    
    // Draw a glowing border around the image
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(15)));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Master Key Dialog
class _MasterKeyDialog extends StatefulWidget {
  @override
  State<_MasterKeyDialog> createState() => _MasterKeyDialogState();
}

class _MasterKeyDialogState extends State<_MasterKeyDialog> {
  final _subjectController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeLevelController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E3A5F),
      title: const Row(
        children: [
          Icon(Icons.key, color: Color(0xFFF59E0B)),
          SizedBox(width: 10),
          Text(
            'Master Key Details',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'e.g., Mathematics, Science',
                prefixIcon: Icon(Icons.book, color: Color(0xFFF59E0B)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF59E0B)),
                ),
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gradeLevelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Grade Level',
                hintText: 'e.g., Grade 10, O/L, A/L',
                prefixIcon: Icon(Icons.school, color: Color(0xFFF59E0B)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF59E0B)),
                ),
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Exam Date',
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFF59E0B)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E3A5F)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF59E0B)),
                ),
                labelStyle: TextStyle(color: Colors.white70),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  _dateController.text = date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 12),
            const Text(
              '* Required field\n'
              'Subject will auto-fill for all students',
              style: TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFFF59E0B))),
        ),
        ElevatedButton(
          onPressed: () {
            if (_subjectController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Please enter subject'),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'subject': _subjectController.text.trim(),
              'grade_level': _gradeLevelController.text.trim().isEmpty 
                  ? 'General' 
                  : _gradeLevelController.text.trim(),
              'exam_date': _dateController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

// Detailed Results Screen
class DetailedResultsScreen extends StatelessWidget {
  final Map<String, dynamic> details;
  final Map<String, dynamic>? studentInfo;
  final int score;
  final int total;
  final double percentage;

  const DetailedResultsScreen({
    super.key,
    required this.details,
    required this.studentInfo,
    required this.score,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    List<String> questionNumbers = details.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    Color scoreColor = percentage >= 75 ? const Color(0xFF10B981) :
                       percentage >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        title: const Text(
          "Detailed Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withOpacity(0.2),
                  const Color(0xFF0A2342),
                ],
              ),
            ),
            child: Column(
              children: [
                if (studentInfo != null) ...[
                  Text(
                    studentInfo!['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${studentInfo!['subject'] ?? 'Unknown'} - ${studentInfo!['grade_level'] ?? 'Unknown'}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  "$score / $total",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 20,
                    color: scoreColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: questionNumbers.length,
              itemBuilder: (context, index) {
                String qNum = questionNumbers[index];
                var detail = details[qNum];
                String result = detail['result'];
                
                Color bgColor, borderColor;
                IconData icon;
                
                if (result == 'correct') {
                  bgColor = const Color(0xFF10B981).withOpacity(0.1);
                  borderColor = const Color(0xFF10B981);
                  icon = Icons.check_circle;
                } else if (result == 'wrong') {
                  bgColor = const Color(0xFFEF4444).withOpacity(0.1);
                  borderColor = const Color(0xFFEF4444);
                  icon = Icons.cancel;
                } else {
                  bgColor = const Color(0xFF6B7280).withOpacity(0.1);
                  borderColor = const Color(0xFF6B7280);
                  icon = Icons.help_outline;
                }
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          qNum,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: borderColor,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      result == 'correct' ? 'Correct ✓' :
                      result == 'wrong' ? 'Wrong ✗' : 'Not Answered',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                    subtitle: Text(
                      'Correct: ${detail['correct']} | Student: ${detail['student']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(icon, color: borderColor, size: 32),
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

// All Results Screen with Filtering
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
    final filteredResults = _filteredResults;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        title: Text(
          'All Results (${filteredResults.length})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: () {
              widget.onExport(
                subject: _selectedSubject,
                gradeLevel: _selectedGradeLevel,
                grade: _selectedGrade,
              );
            },
            tooltip: 'Export Filtered Results',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E3A5F).withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Results:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (widget.availableFilters?['subjects'] != null) ...[
                        _buildFilterChip(
                          label: 'Subject',
                          value: _selectedSubject,
                          options: widget.availableFilters!['subjects'],
                          onSelected: (value) {
                            setState(() => _selectedSubject = value);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.availableFilters?['grade_levels'] != null) ...[
                        _buildFilterChip(
                          label: 'Grade Level',
                          value: _selectedGradeLevel,
                          options: widget.availableFilters!['grade_levels'],
                          onSelected: (value) {
                            setState(() => _selectedGradeLevel = value);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.availableFilters?['grades'] != null) ...[
                        _buildFilterChip(
                          label: 'Grade',
                          value: _selectedGrade,
                          options: widget.availableFilters!['grades'],
                          onSelected: (value) {
                            setState(() => _selectedGrade = value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (_selectedSubject != null || _selectedGradeLevel != null || _selectedGrade != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedSubject = null;
                        _selectedGradeLevel = null;
                        _selectedGrade = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all, color: Color(0xFF10B981)),
                    label: const Text('Clear Filters', style: TextStyle(color: Color(0xFF10B981))),
                  ),
              ],
            ),
          ),
          
          // Results List
          Expanded(
            child: filteredResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 100, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'No results matching filters',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = filteredResults[index];
                      final percentage = (result['percentage'] as num).toDouble();
                      Color gradeColor = percentage >= 75 ? const Color(0xFF10B981) :
                                        percentage >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: gradeColor,
                              radius: 28,
                              child: Text(
                                result['grade'] ?? '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${result['subject']} - ${result['grade_level']}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${result['medium']} • ${result['exam_date']}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${result['score']}/${result['total_questions']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: gradeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
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
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<dynamic> options,
    required Function(String?) onSelected,
  }) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value != null 
              ? const Color(0xFF10B981).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value != null 
                ? const Color(0xFF10B981)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) 
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
            else
              const Icon(Icons.filter_list, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              value ?? label,
              style: TextStyle(
                color: value != null ? const Color(0xFF10B981) : Colors.white,
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, color: Color(0xFF10B981), size: 18),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => [
        ...options.map((option) => PopupMenuItem(
          value: option.toString(),
          child: Text(
            option.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        )),
      ],
      color: const Color(0xFF1E3A5F),
      onSelected: onSelected,
    );
  }
}