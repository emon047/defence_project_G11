import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class MoodAnalyticsPage extends StatelessWidget {
  const MoodAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Weekly Vibe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: BarChart(BarChartData(
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppColors.deepPurple, width: 15)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6, color: AppColors.auroraTeal, width: 15)]),
              ],
            )),
          ),
          const SizedBox(height: 30),
          _statTile("Happiness Balance", "84%", Icons.auto_awesome),
          const SizedBox(height: 15),
          // FIXED: psychology_outlined (lowercase p)
          _statTile("Stress Levels", "Low", Icons.psychology_outlined),
        ],
      ),
    );
  }

  Widget _statTile(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, color: AppColors.deepPurple), const SizedBox(width: 10), Text(label)]),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}