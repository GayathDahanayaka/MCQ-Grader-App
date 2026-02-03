import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MCQGraderApp());
}

class MCQGraderApp extends StatelessWidget {
  const MCQGraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced OMR Grader',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  String _statusMessage = "Welcome! Advanced OMR Grader v12.0 📝";
  Map<String, dynamic>? _studentInfo;
  Map<String, dynamic>? _gradeResults;
  bool _isLoading = false;
  bool _masterKeySet = false;
  bool _serverOnline = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ⚠️ IMPORTANT: Update this with YOUR computer's IP address
  // Find it by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  final String _baseUrl = 'http://192.168.8.127:5000';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _checkServerConnection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/test')).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _serverOnline = true;
          _statusMessage = "✅ Server connected! Advanced OMR Grader v12.0 ready.\n\n"
              "✓ Precise bubble detection\n"
              "✓ Correct answer mapping\n"
              "✓ English OCR for names";
        });
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        _serverOnline = false;
        _statusMessage = "⚠️ Cannot connect to server.\n\n"
            "Please ensure:\n"
            "1. Python server is running (python omr_engine_fixed.py)\n"
            "2. IP address is correct: $_baseUrl\n"
            "3. Phone and computer are on same WiFi network";
      });
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
          _statusMessage = "✓ Image selected successfully! Choose an action below.";
          _studentInfo = null;
          _gradeResults = null;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      _showErrorDialog("Error selecting image", e.toString());
    }
  }

  Future<void> _uploadAndProcess(String endpoint) async {
    if (_selectedImage == null) {
      _showErrorDialog("No Image Selected", "Please select an image first!");
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = endpoint == 'upload_master' 
          ? "📝 Processing master answer key... Please wait."
          : "📊 Grading student sheet... Analyzing answers.";
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$endpoint'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        
        setState(() {
          if (endpoint == 'upload_master') {
            _masterKeySet = true;
            _statusMessage = "✅ Master Key Set Successfully!\n\n"
                "Detected ${data['valid_answers']} out of ${data['total']} answers.\n\n"
                "Example answers:\n"
                "${_formatAnswerPreview(data['answers'])}";
            _gradeResults = null;
            _studentInfo = null;
          } else {
            _statusMessage = "✅ Grading Complete!";
            
            // Parse student info
            String infoStr = data['student_info'] ?? "";
            _studentInfo = {
              'name': _extractValue(infoStr, 'Name'),
              'subject': _extractValue(infoStr, 'Subject'),
              'medium': _extractValue(infoStr, 'Medium'),
            };
            
            _gradeResults = {
              'score': data['total_score'],
              'total': data['out_of'],
              'correct': data['correct'],
              'wrong': data['wrong'],
              'unanswered': data['unanswered'],
              'percentage': data['percentage'],
              'details': data['details'],
            };
            
            // Show success animation
            _animationController.forward(from: 0);
            _showSuccessDialog();
          }
        });
      } else {
        var errorData = json.decode(response.body);
        setState(() {
          _statusMessage = "❌ Error: ${errorData['error'] ?? 'Unknown error'}";
        });
        _showErrorDialog(
          "Processing Failed",
          errorData['message'] ?? errorData['error'] ?? 'Unknown error'
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Connection Failed!";
      });
      _showErrorDialog(
        "Connection Error",
        "Cannot connect to server.\n\n"
        "Please check:\n"
        "1. Python server is running\n"
        "2. IP address is correct: $_baseUrl\n"
        "3. Phone and computer are on same WiFi\n\n"
        "Error details: $e"
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatAnswerPreview(Map<String, dynamic> answers) {
    List<String> preview = [];
    int count = 0;
    for (var entry in answers.entries) {
      if (count >= 5) break;
      preview.add("Q${entry.key}=${entry.value}");
      count++;
    }
    return preview.join(", ");
  }

  String _extractValue(String text, String key) {
    try {
      RegExp exp = RegExp('$key:\\s*(.+?)(?=\\n|\$)', caseSensitive: false);
      var match = exp.firstMatch(text);
      return match?.group(1)?.trim() ?? 'Not detected';
    } catch (e) {
      return 'Not detected';
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    if (_gradeResults == null) return;
    
    final percentage = _gradeResults!['percentage'] as double;
    final score = _gradeResults!['score'];
    final total = _gradeResults!['total'];
    
    String grade;
    Color gradeColor;
    IconData gradeIcon;
    
    if (percentage >= 90) {
      grade = 'A+';
      gradeColor = Colors.green;
      gradeIcon = Icons.star;
    } else if (percentage >= 80) {
      grade = 'A';
      gradeColor = Colors.green;
      gradeIcon = Icons.star_half;
    } else if (percentage >= 70) {
      grade = 'B';
      gradeColor = Colors.blue;
      gradeIcon = Icons.thumb_up;
    } else if (percentage >= 60) {
      grade = 'C';
      gradeColor = Colors.orange;
      gradeIcon = Icons.done;
    } else {
      grade = 'D';
      gradeColor = Colors.red;
      gradeIcon = Icons.trending_down;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(gradeIcon, color: gradeColor, size: 32),
            const SizedBox(width: 10),
            const Text('Grading Complete!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
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
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildScoreSummary(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDetailedResults();
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreItem(
          '✅',
          _gradeResults!['correct'].toString(),
          'Correct',
          Colors.green,
        ),
        _buildScoreItem(
          '❌',
          _gradeResults!['wrong'].toString(),
          'Wrong',
          Colors.red,
        ),
        _buildScoreItem(
          '⚪',
          _gradeResults!['unanswered'].toString(),
          'Skipped',
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildScoreItem(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showDetailedResults() {
    if (_gradeResults == null || _gradeResults!['details'] == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedResultsScreen(
          details: _gradeResults!['details'],
          studentInfo: _studentInfo,
          score: _gradeResults!['score'],
          total: _gradeResults!['total'],
          percentage: _gradeResults!['percentage'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Advanced OMR Grader v12.0",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_serverOnline ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _checkServerConnection,
            tooltip: _serverOnline ? 'Server Online' : 'Server Offline',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
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
                // Status Banner
                _buildStatusBanner(),
                const SizedBox(height: 16),

                // Image Display Card
                _buildImageCard(),
                const SizedBox(height: 16),

                // Camera & Gallery Buttons
                _buildImageSourceButtons(),
                const SizedBox(height: 24),

                // Action Buttons
                if (_selectedImage != null) ...[
                  _buildMasterKeyButton(),
                  const SizedBox(height: 12),
                  _buildGradeStudentButton(),
                  const SizedBox(height: 24),
                ],

                // Loading Indicator
                if (_isLoading) _buildLoadingIndicator(),

                // Status Message
                _buildStatusMessage(),

                // Student Info Card
                if (_studentInfo != null) ...[
                  const SizedBox(height: 16),
                  _buildStudentInfoCard(),
                ],

                // Score Card
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _masterKeySet 
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (_masterKeySet ? Colors.green : Colors.blue).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _masterKeySet ? Icons.check_circle : Icons.info,
              color: _masterKeySet ? Colors.green : Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _masterKeySet 
                  ? "Master key is set ✓\nReady to grade students!"
                  : "Step 1: Upload master answer key",
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
    return Card(
      elevation: 8,
      shadowColor: Colors.indigo.withValues(alpha: 0.3),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, 
                       size: 100, 
                       color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No image selected",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap camera or gallery below",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }

  Widget _buildImageSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt, size: 24),
            label: const Text("Camera", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library, size: 24),
            label: const Text("Gallery", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMasterKeyButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _uploadAndProcess('upload_master'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.key, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              "STEP 1: SET MASTER KEY",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeStudentButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _masterKeySet 
              ? [Colors.green, Colors.teal]
              : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _masterKeySet ? [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_masterKeySet) 
            ? null 
            : () => _uploadAndProcess('grade_student'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grade,
              color: _masterKeySet ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "STEP 2: GRADE STUDENT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _masterKeySet ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.blue.shade50,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Processing image...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.indigo,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.indigo.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.indigo, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "Student Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.person_outline, "Name", _studentInfo!['name']),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.book, "Subject", _studentInfo!['subject']),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.language, "Medium", _studentInfo!['medium']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.indigo.shade700),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    final percentage = _gradeResults!['percentage'] as double;
    Color scoreColor;
    
    if (percentage >= 75) {
      scoreColor = Colors.green;
    } else if (percentage >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [scoreColor.withValues(alpha: 0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const Text(
                "Final Score",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 4),
                ),
                child: Column(
                  children: [
                    Text(
                      "${_gradeResults!['score']}",
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      "/ ${_gradeResults!['total']}",
                      style: TextStyle(
                        fontSize: 24,
                        color: scoreColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreSummary(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showDetailedResults,
                icon: const Icon(Icons.list_alt),
                label: const Text("View Detailed Results"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

    Color scoreColor;
    if (percentage >= 75) {
      scoreColor = Colors.green;
    } else if (percentage >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detailed Results"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor.withValues(alpha: 0.1), Colors.white],
              ),
            ),
            child: Column(
              children: [
                if (studentInfo != null) ...[
                  Text(
                    studentInfo!['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${studentInfo!['subject']} • ${studentInfo!['medium']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$score / $total",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Question-wise results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: questionNumbers.length,
              itemBuilder: (context, index) {
                String qNum = questionNumbers[index];
                var detail = details[qNum];
                String result = detail['result'];
                
                Color bgColor;
                Color borderColor;
                IconData icon;
                
                if (result == 'correct') {
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green;
                  icon = Icons.check_circle;
                } else if (result == 'wrong') {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red;
                  icon = Icons.cancel;
                } else {
                  bgColor = Colors.grey.shade50;
                  borderColor = Colors.grey;
                  icon = Icons.help_outline;
                }
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      result == 'correct'
                          ? 'Correct ✓'
                          : result == 'wrong'
                              ? 'Wrong ✗'
                              : 'Not Answered',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: borderColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Correct: ${detail['correct']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Student: ${detail['student']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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