import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ptyxiaki/location/dynamicMap.dart';
import 'package:ptyxiaki/screens/ItemScreen.dart';
import 'package:ptyxiaki/clas/Item.dart';
import 'SettingsPage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
class ImageInput extends StatefulWidget {
  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  late Future<void> loadFuture;
  File? image;

  Future<bool> takePicture() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final imagePicker = ImagePicker();
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    loadFuture=Provider.of<ItemBrain>(context, listen: false).loadList();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          }, icon: Icon(Icons.settings)),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool result = await InternetConnectionChecker().hasConnection;
          if (result ==false) {
            // Internet connection exists, show an error message or handle accordingly
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("This action cannot be performed while connected to the internet."),
            ));
          } else {
            // No internet connection, proceed with taking a picture
            bool imagePicked = await takePicture();
            if (imagePicked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ItemScreen(image: image)),
              );
            }
          }
        },
        icon: Icon(Icons.add),
        label: Text('Take a new picture'),
      ),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Expanded(
              child: FutureBuilder(
                future: loadFuture, // This should be the future initialized in initState().
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display a loading indicator while waiting for the future to complete.
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // If the future completes with an error, display an error message.
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    // Once the future completes successfully, use a Consumer widget to build the UI based on the current state.
                    return Consumer<ItemBrain>(
                      builder: (context, brainItem, child) {
                        if (brainItem.itemList.isEmpty) {
                          // Display a message if the list is empty.
                          return Center(child: Text('List is empty'));
                        } else {
                          // If the list contains items, build a ListView to display them.
                          return ListView.builder(
                            itemCount: brainItem.itemList.length,
                            itemBuilder: (context, index) {
                              Item item = brainItem.itemList[index];
                              // Each item in the list is wrapped in a Dismissible widget to allow users to remove items by swiping.
                              return Dismissible(
                                key: ValueKey(item.dateTime),
                                onDismissed: (direction) async {
                                  // Check for internet connection
                                  bool result = await InternetConnectionChecker().hasConnection;
                                  if (result == false) {
                                    // No internet connection, do not proceed with removing the item.
                                    // Optionally, show a message to the user indicating that an internet connection is required.
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("An internet connection is required to perform this action."),
                                    ));
                                  } else {
                                    // Internet connection is available, proceed with removing the item.
                                    Provider.of<ItemBrain>(context, listen: false).removeItem(index);
                                  }
                                },

                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    border: Border.all(width: 1, color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  height: 200,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 150,
                                        child: Image.file(item.image!, fit: BoxFit.cover),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(item.type!, style: TextStyle(fontSize: 18)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                              child: Text(DateFormat('yyyy-MM-dd – kk:mm').format(item.dateTime!), style: TextStyle(fontSize: 12)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_on, size: 16),
                                                  SizedBox(width: 5),
                                                  Text('${item.lat.toString()}, ${item.long.toString()}', style: TextStyle(fontSize: 14)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}