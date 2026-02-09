import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcq_grader/src/widgets/gradient_background.dart';
import 'package:mcq_grader/src/widgets/glass_card.dart';
import 'package:mcq_grader/src/widgets/modern_button.dart';
import 'package:mcq_grader/src/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultsScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final score = resultData['score'];
    final total = resultData['total'];
    final percentage = resultData['percentage'];
    final correct = resultData['correct'];
    final wrong = resultData['wrong'];
    final unanswered = resultData['unanswered'];
    final detailsMap = resultData['details'] as Map<String, dynamic>;
    final details = detailsMap.entries.map((e) {
      final val = e.value as Map<String, dynamic>;
      return {
        'q_num': e.key,
        'correct_ans': val['correct'],
        'student_ans': val['student'],
        'result': val['result'], 
      };
    }).toList();
    
    // Sort by question number
    details.sort((a, b) => int.parse(a['q_num']).compareTo(int.parse(b['q_num'])));

    final student = resultData['student_info'];

    Color gradeColor = Colors.green;
    String grade = 'F';
    if (percentage >= 90) { grade = 'A+'; gradeColor = Colors.green; }
    else if (percentage >= 80) { grade = 'A'; gradeColor = Colors.green; }
    else if (percentage >= 75) { grade = 'A-'; gradeColor = Colors.lightGreen; }
    else if (percentage >= 70) { grade = 'B+'; gradeColor = Colors.blue; }
    else if (percentage >= 65) { grade = 'B'; gradeColor = Colors.blueAccent; }
    else if (percentage >= 60) { grade = 'C+'; gradeColor = Colors.orange; }
    else if (percentage >= 50) { grade = 'C'; gradeColor = Colors.orangeAccent; }
    else if (percentage >= 35) { grade = 'S'; gradeColor = Colors.deepOrange; }
    else { grade = 'F'; gradeColor = Colors.red; }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Results", style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Score Header
              const SizedBox(height: 20),
              Column(
                children: [
                   Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gradeColor, width: 4),
                      boxShadow: [BoxShadow(color: gradeColor.withOpacity(0.4), blurRadius: 20)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      grade,
                      style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: gradeColor),
                    ),
                  ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
                  const SizedBox(height: 16),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ).animate().fadeIn().slideY(begin: 0.2),
                  Text(
                    "$score / $total Marks",
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("Correct", correct.toString(), Colors.green),
                  _buildStatItem("Wrong", wrong.toString(), Colors.red),
                  _buildStatItem("Blank", unanswered.toString(), Colors.grey),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 30),

              // Student Info
              GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.indigoAccent, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['name'] ?? 'Unknown', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(student['student_id'] ?? 'No ID', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(),

              const SizedBox(height: 20),
              
              const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Align(alignment: Alignment.centerLeft, child: Text("Detailed Breakdown", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 10),

              // Detailed List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final item = details[index];
                    final isCorrect = item['result'] == 'correct';
                    final isWrong = item['result'] == 'wrong';
                    final color = isCorrect ? Colors.green : (isWrong ? Colors.red : Colors.grey);
                    final icon = isCorrect ? Icons.check : (isWrong ? Icons.close : Icons.remove);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: color, width: 4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                            child: Text(item['q_num'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Student Answer: ${item['student_ans']}", style: TextStyle(color: Colors.white70)),
                                Text("Correct Answer: ${item['correct_ans']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ),
                          Icon(icon, color: color),
                        ],
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: ModernButton(
                  label: "Return to Home",
                  icon: Icons.home,
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
