import 'package:flutter/material.dart';
import '../core/theme.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text(
          "All Memories",
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.spaceDark),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip("Date", true),
                  const SizedBox(width: 10),
                  _filterChip("Mood", false),
                  const SizedBox(width: 10),
                  _filterChip("Emotions", false),
                  const SizedBox(width: 10),
                  _filterChip("Location", false),
                ],
              ),
            ),
          ),
          
          // Grid of Memories in Bento Style
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _memoryTile(
                  "Coffee by the lake", 
                  "https://images.unsplash.com/photo-1509042239860-f550ce710b93", 
                  AppColors.softLavender
                ),
                _memoryTile(
                  "Evening walk", 
                  "https://images.unsplash.com/photo-1507525428034-b723cf961d3e", 
                  const Color(0xFFFDE68A)
                ),
                _memoryTile(
                  "Relaxed day", 
                  null, 
                  AppColors.auroraTeal.withOpacity(0.1)
                ),
                _memoryTile(
                  "Happy Moment", 
                  null, 
                  const Color(0xFFFECACA)
                ),
                _memoryTile(
                  "Mountain Hike", 
                  "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b", 
                  AppColors.deepPurple.withOpacity(0.1)
                ),
                _memoryTile(
                  "Study Session", 
                  null, 
                  Colors.blueGrey.withOpacity(0.1)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Chip Helper
  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.deepPurple : AppColors.deepPurple.withOpacity(0.1)
        ),
        boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
            : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // Memory Grid Tile Helper
  Widget _memoryTile(String title, String? imgUrl, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        image: imgUrl != null 
            ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover) 
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          // Glassmorphic overlay for the title
          color: Colors.white.withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.spaceDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}