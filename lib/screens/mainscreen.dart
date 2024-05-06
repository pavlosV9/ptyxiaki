import 'package:flutter/material.dart';
import 'package:ptyxiaki/screens/camerapage.dart'; // Make sure this path is correct
// Import ImageInput if it's in a different file

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mainimage.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Text content
          Positioned(
            top: 60,
            left: 10,
            child: Text(
              'Welcome to Pedestrian App Nicosia',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            child: Text(
              'Protect your city',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Positioned(
            top: 350,
            left: MediaQuery.of(context).size.width / 3.5,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(

                  MaterialPageRoute(builder: (context) => ImageInput()), // Assuming ImageInput is the correct destination
                );
              },
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  border: Border.all(color: Colors.white54, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),




                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Add more widgets here as needed
        ],
      ),
    );
  }
}
