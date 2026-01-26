import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme.dart';

// FIXED: Class name changed to MemoryMapPage
class MemoryMapPage extends StatelessWidget {
  const MemoryMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(23.8103, 90.4125), 
              zoom: 12
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: const Icon(Icons.arrow_back, color: AppColors.spaceDark)
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), 
                    blurRadius: 20
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25, 
                    backgroundColor: AppColors.auroraTeal, 
                    child: Icon(Icons.park, color: Colors.white)
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Afternoon at the Park", 
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Text(
                        "Dhaka • 2 memories here", 
                        style: TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}