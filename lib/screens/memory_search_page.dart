import 'package:flutter/material.dart';
import '../core/theme.dart';

class MemorySearchPage extends StatelessWidget {
  const MemorySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Memories")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search keywords...",
                  prefixIcon: Icon(Icons.search, color: AppColors.deepPurple),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _searchChip("Happy"), _searchChip("Beach"), _searchChip("2024"), _searchChip("Rainy"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: AppColors.softLavender, borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: const TextStyle(color: AppColors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}