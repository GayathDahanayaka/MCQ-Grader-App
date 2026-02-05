import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
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
  String _statusMessage = "Welcome! Enhanced OMR Grader Pro v3.0 🎓";
  Map<String, dynamic>? _studentInfo;
  Map<String, dynamic>? _gradeResults;
  Map<String, dynamic>? _masterMetadata;
  bool _isLoading = false;
  bool _masterKeySet = false;
  bool _serverOnline = false;
  
  // Student input controllers (subject removed - auto-filled from master)
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _mediumController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _checkServerConnection();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _mediumController.dispose();
    _animationController.dispose();
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
            backgroundColor: Colors.green,
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
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Student Information'),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subject (from master key)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _masterMetadata!['subject'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Grade Level (from master key)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _masterMetadata!['grade_level'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                decoration: const InputDecoration(
                  labelText: 'Student ID (Optional)',
                  hintText: 'e.g., 2024001',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  hintText: 'Enter student name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mediumController,
                decoration: const InputDecoration(
                  labelText: 'Medium (Optional)',
                  hintText: 'e.g., English, Sinhala, Tamil',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '* Required field\n'
                'Subject and grade auto-filled from master key\n'
                'System will auto-detect other fields if not provided',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_studentNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Please enter student name'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
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
            backgroundColor: Colors.green,
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
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
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
    
    final percentage = (_gradeResults!['percentage'] as num).toDouble();
    final score = _gradeResults!['score'];
    final total = _gradeResults!['total'];
    
    String grade;
    Color gradeColor;
    
    if (percentage >= 90) {
      grade = 'A+';
      gradeColor = Colors.green;
    } else if (percentage >= 80) {
      grade = 'A';
      gradeColor = Colors.green;
    } else if (percentage >= 70) {
      grade = 'B';
      gradeColor = Colors.blue;
    } else if (percentage >= 60) {
      grade = 'C';
      gradeColor = Colors.orange;
    } else if (percentage >= 50) {
      grade = 'D';
      gradeColor = Colors.deepOrange;
    } else {
      grade = 'F';
      gradeColor = Colors.red;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: gradeColor, size: 32),
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
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDetailedResults();
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
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
      appBar: AppBar(
        title: const Text(
          "Enhanced OMR Grader Pro v3.0",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_serverOnline ? Icons.cloud_done : Icons.cloud_off, color: Colors.white),
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
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Export to Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'results',
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('View All Results'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Refresh Connection'),
                  ],
                ),
              ),
            ],
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
      bannerColors = [Colors.green.shade400, Colors.green.shade600];
      bannerIcon = Icons.check_circle;
    } else if (_serverOnline) {
      bannerText = "Step 1: Upload master key";
      bannerColors = [Colors.blue.shade400, Colors.blue.shade600];
      bannerIcon = Icons.info;
    } else {
      bannerText = "⚠️ Server offline";
      bannerColors = [Colors.grey.shade400, Colors.grey.shade600];
      bannerIcon = Icons.error_outline;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bannerColors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
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
                    "Tap Camera or Gallery below",
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _uploadMasterKey,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_masterKeySet) ? null : _gradeStudent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              "GRADE STUDENT",
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            const SizedBox(height: 16),
            Text(
              "Processing...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.indigo, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage, 
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final percentage = (_gradeResults!['percentage'] as num).toDouble();
    Color scoreColor = percentage >= 75 ? Colors.green : 
                       percentage >= 50 ? Colors.orange : Colors.red;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, scoreColor.withOpacity(0.05)],
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
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.cancel,
                  'Wrong',
                  _gradeResults!['wrong'].toString(),
                  Colors.red,
                ),
                _buildStatItem(
                  Icons.help_outline,
                  'Unanswered',
                  _gradeResults!['unanswered'].toString(),
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showDetailedResults,
              icon: const Icon(Icons.list_alt),
              label: const Text("View Detailed Results"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
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
      title: const Row(
        children: [
          Icon(Icons.key, color: Colors.orange),
          SizedBox(width: 10),
          Text('Master Key Details'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'e.g., Mathematics, Science',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gradeLevelController,
              decoration: const InputDecoration(
                labelText: 'Grade Level',
                hintText: 'e.g., Grade 10, O/L, A/L',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Exam Date',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
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
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_subjectController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Please enter subject'),
                  backgroundColor: Colors.orange,
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
            backgroundColor: Colors.orange,
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

    Color scoreColor = percentage >= 75 ? Colors.green :
                       percentage >= 50 ? Colors.orange : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detailed Results"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor.withOpacity(0.1), Colors.white],
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${studentInfo!['subject'] ?? 'Unknown'} - ${studentInfo!['grade_level'] ?? 'Unknown'}",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
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
                      result == 'correct' ? 'Correct ✓' :
                      result == 'wrong' ? 'Wrong ✗' : 'Not Answered',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                    subtitle: Text(
                      'Correct: ${detail['correct']} | Student: ${detail['student']}',
                      style: TextStyle(color: Colors.grey[700]),
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
      appBar: AppBar(
        title: Text('All Results (${filteredResults.length})'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
          ),
        ),
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
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Results:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
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
                        Icon(Icons.inbox, size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No results matching filters',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                      Color gradeColor = percentage >= 75 ? Colors.green :
                                        percentage >= 50 ? Colors.orange : Colors.red;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
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
                          title: Text(
                            result['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${result['subject']} - ${result['grade_level']}'),
                              Text('${result['medium']} • ${result['exam_date']}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${result['score']}/${result['total_questions']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
      child: Chip(
        avatar: value != null 
            ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
            : const Icon(Icons.filter_list, size: 18),
        label: Text(value ?? label),
        backgroundColor: value != null ? Colors.green.shade50 : Colors.grey.shade200,
        deleteIcon: value != null ? const Icon(Icons.close, size: 18) : null,
        onDeleted: value != null ? () => onSelected(null) : null,
      ),
      itemBuilder: (context) => [
        ...options.map((option) => PopupMenuItem(
          value: option.toString(),
          child: Text(option.toString()),
        )),
      ],
      onSelected: onSelected,
    );
  }
}