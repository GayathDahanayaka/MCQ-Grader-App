import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcq_grader/src/widgets/gradient_background.dart';
import 'package:mcq_grader/src/widgets/glass_card.dart';
import 'package:mcq_grader/src/widgets/status_badge.dart';
import 'package:mcq_grader/src/widgets/dashboard_card.dart';
import 'package:mcq_grader/src/services/api_service.dart';
import 'package:mcq_grader/src/screens/grading_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mcq_grader/src/screens/all_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  bool _serverOnline = false;
  Map<String, dynamic>? _masterData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    
    // Check server
    final serverRes = await _api.checkConnection();
    final isOnline = serverRes['success'];
    
    // Check master key if server is online
    Map<String, dynamic>? masterData;
    if (isOnline) {
      final masterRes = await _api.getMasterMetadata();
      if (masterRes['success']) {
        masterData = masterRes;
      }
    }

    if (mounted) {
      setState(() {
        _serverOnline = isOnline;
        _masterData = masterData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "Dashboard",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _checkStatus,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: -0.2).fadeIn(),

                const SizedBox(height: 24),

                // Status Bar
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatusBadge(
                        label: _serverOnline ? "Server Online" : "Server Offline",
                        isActive: _serverOnline,
                        icon: _serverOnline ? Icons.cloud_done : Icons.cloud_off,
                      ),
                      Container(width: 1, height: 24, color: Colors.white24),
                      StatusBadge(
                        label: _masterData != null ? "Master Key Set" : "No Master Key",
                        isActive: _masterData != null,
                        icon: _masterData != null ? Icons.key : Icons.key_off,
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms),

                const SizedBox(height: 32),

                // Master Key Info Widget (if active)
                if (_masterData != null && _serverOnline)
                  GlassCard(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description, color: Colors.indigoAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Active Exam Config", 
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow("Subject", _masterData!['subject']),
                        const SizedBox(height: 8),
                        _buildInfoRow("Grade Level", _masterData!['grade_level']),
                        const SizedBox(height: 8),
                        _buildInfoRow("Date", _masterData!['exam_date']),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                Text(
                  "Quick Actions",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 16),

                // Grid Actions
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      DashboardCard(
                        index: 1,
                        title: "Start Grading",
                        subtitle: "Scan student answer sheets",
                        icon: Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        onTap: () {
                          if (!_serverOnline) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Server is offline! Check connection.")),
                            );
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const GradingScreen()));
                        },
                      ),
                      DashboardCard(
                        index: 2,
                        title: "View Results",
                        subtitle: "Analyze class performance",
                        icon: Icons.analytics_rounded,
                        color: Colors.purpleAccent,
                        onTap: () {
                           if (!_serverOnline) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Server is offline! Check connection.")),
                            );
                            return;
                          }
                          // Fetch results first
                          _api.getAllResults().then((data) async {
                            if (data['success'] != false) {
                              var resultsRaw = data['results'];
                              List<Map<String, dynamic>> resultsList = [];
                              
                              if (resultsRaw is List) {
                                resultsList = resultsRaw.map((e) => Map<String, dynamic>.from(e)).toList();
                              } else if (resultsRaw is Map) {
                                debugPrint("Warning: results is a Map, attempting to use values");
                                resultsList = resultsRaw.values.map((e) => Map<String, dynamic>.from(e)).toList();
                              }

                              // Fetch filters
                              Map<String, dynamic>? filters;
                              final filterData = await _api.getFilters();
                              if (filterData['success'] != false) {
                                filters = filterData['filters'];
                              }

                              if (context.mounted) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AllResultsScreen(
                                  results: resultsList,
                                  availableFilters: filters,
                                  onExport: ({subject, gradeLevel, grade}) async {
                                    final bytes = await _api.exportExcel(
                                      subject: subject,
                                      gradeLevel: gradeLevel,
                                      grade: grade,
                                    );
                                    
                                    if (bytes != null && context.mounted) {
                                      try {
                                        final directory = await getTemporaryDirectory();
                                        final path = '${directory.path}/grading_results.xlsx';
                                        final file = File(path);
                                        await file.writeAsBytes(bytes);
                                        
                                        await Share.shareXFiles([XFile(path)], text: 'Grading Results Export');
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing file: $e")));
                                        }
                                      }
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Export failed")));
                                    }
                                  },
                                )));
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['error'] ?? "Failed to fetch results")));
                              }
                            }
                          });
                        },
                      ),
                      // Add more cards later if needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
