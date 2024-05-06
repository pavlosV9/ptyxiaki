import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ptyxiaki/screens/camerapage.dart';
import 'package:ptyxiaki/screens/mapScreen.dart';
import 'package:ptyxiaki/screens/welcomeScreen.dart';
import 'package:ptyxiaki/clas/Item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Welcomescreen()),
              );
            },
            child: Column(
              children: [
                GestureDetector(
                onTap: () {
        Navigator.push(
            context,
                MaterialPageRoute(builder: (context) => Welcomescreen()),
                );
                   },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10), // Add margin around the container
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Adjust padding for better spacing
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      border: Border.all(
                        color: Colors.green, // Border color
                        width: 2, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      'Show App Intro',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    var itemBrain = Provider.of<ItemBrain>(context, listen: false);
                    itemBrain.removeList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageInput()),
                    );
                    },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10), // Add margin around the container
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Adjust padding for better spacing
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      border: Border.all(
                        color: Colors.green, // Border color
                        width: 2, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      'Delete all',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10), // Add margin around the container
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Adjust padding for better spacing
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      border: Border.all(
                        color: Colors.green, // Border color
                        width: 2, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      'Show Map',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Text color
                      ),
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
}
