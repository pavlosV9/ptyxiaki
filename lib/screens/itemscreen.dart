import 'package:flutter/material.dart';
import 'package:ptyxiaki/clas/Item.dart';
import 'package:ptyxiaki/http/addItem.dart';
import 'package:ptyxiaki/location/dynamicMap.dart';
import 'package:ptyxiaki/location/location.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ptyxiaki/screens/camerapage.dart';
import 'package:pytorch_mobile/pytorch_mobile.dart';
import 'package:pytorch_mobile/model.dart';
import 'package:image/image.dart' as img;
import 'package:ptyxiaki/pytorch_logic/pytroch.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class ItemScreen extends StatefulWidget {
  ItemScreen({this.image});
  File? image;
  @override
  State<ItemScreen> createState() => _ItemScreenState();
}


class _ItemScreenState extends State<ItemScreen> {

  late Model _model;
  final PytorchLogic pytorchLogic = PytorchLogic();
  String _prediction = "press button to predict";
  bool _isFetchingLocation = true;

  Item newItem= Item();
  ItemBrain itemBrain=ItemBrain();
  String? _customObstacleType;


  Future loadModel() async {
    _model = await PyTorchMobile.loadModel("assets/mobilenet_v2_29_classes.pt");
    runModel();
    print("Model loaded successfully");

  }

  Future<void> runModel() async {
    if (widget.image == null) {
      print('No image selected for prediction.');
      return;
    }

    // Preprocess the image using PytorchLogic
    img.Image? preprocessedImage = await pytorchLogic.preprocessImage(widget.image!);
    if (preprocessedImage == null) {
      print("Error in image preprocessing.");
      return;
    }

    // Convert preprocessed image back to file using PytorchLogic
    File preprocessedFile = await pytorchLogic.imageToFile(preprocessedImage, "preprocessed.jpg");

    // Assuming the model accepts preprocessed images directly
    String prediction = await _model.getImagePrediction(
      preprocessedFile,
      224,
      224,
      "assets/obstacle_types.txt",
      mean: [0.485, 0.456, 0.406],
      std: [0.229, 0.224, 0.225],
    );

    print('Model prediction: $prediction');
    setState(() {
      _prediction = prediction;
    });
  }

  @override
  void initState() {
    setState(() {
      locationService.getLocation();
      newItem.image=widget.image;
      fetchLocation();
      loadModel();
    });

  }

  void fetchLocation() async {
    setState(() {
      _isFetchingLocation = true; // Start fetching location
    });

    LocationData? locationData = await locationService.getLocation();
    if (locationData != null) {
      newItem.lat = locationData.latitude!;
      newItem.long = locationData.longitude!;
    }

    setState(() {
      _isFetchingLocation = false; // Done fetching location
    });
  }


  final _formKey = GlobalKey<FormState>(); // Add this line
  String? _selectedOption;
  MyLocationService locationService = MyLocationService();
  // List of options
  final List<String> _options = ["2_wheel_vehicle", "4_wheel_vehicle", "advertisement_sign", "bench", "bin", "boulder", "bus_stop", "chair", "crack", "crowded_pavement", "fence", "flower", "hole_pot_hole", "information_tourist_sign", "light", "litter", "mail_box", "narrow_pavement", "no_pavement", "parking_meter", "parking_prevention_barrier", "paver_broken", "plant_pot", "safety_sign", "scaffolding", "shrub", "table", "traffic_cone", "tree", "Other"];


  void _validateAndSubmit() async {
    if (_selectedOption == null || (_selectedOption == 'Other' && (_customObstacleType == null || _customObstacleType!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form properly.')),
      );
      return;
    }
    newItem.type = _selectedOption == 'Other' ? _customObstacleType : _selectedOption;

    if (widget.image != null) {
      // Preprocess the image.
      img.Image? preprocessedImage = await pytorchLogic.preprocessImage(widget.image!);
      if (preprocessedImage != null) {
        // Convert the preprocessed image back to a File.
        File preprocessedFile = await pytorchLogic.imageToFile(preprocessedImage, 'preprocessed_image.jpg');
        // Update newItem.image with the preprocessed image file.
        newItem.image = preprocessedFile;
        // Proceed with model prediction.
        await runModel();
      } else {
        print("Error preprocessing the image.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            bool result = await InternetConnectionChecker().hasConnection;

            if (result==false) {
              // No internet connection, show an error message
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("An internet connection is required to perform this action."),
              ));
            } else {
              // Internet connection is available, proceed with actions
              _validateAndSubmit();

              newItem.dateTime = DateTime.now();

              if (newItem.image != null && newItem.long != null && newItem.dateTime != null &&
                  newItem.type != null && newItem.lat != null) {
                Provider.of<ItemBrain>(context, listen: false).addToListHybrid(
                  newItem.image!,
                  newItem.dateTime!,
                  newItem.type!,
                  newItem.lat!,
                  newItem.long!,
                );
                Provider.of<ItemBrain>(context, listen: false).uploadImage(newItem.image!);

                addItem(newItem.type!, newItem.lat!, newItem.long!, newItem.dateTime!);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ImageInput()), // Assuming ImageInput is the correct destination
                );
              }
              print(newItem.image);
              print(newItem.lat);
              print(newItem.dateTime);
              print(newItem.long);
              print(newItem.type);
            }
          },
          icon: const Icon(Icons.add), // Icon widget
          label: const Text('Add Item'), // Text widget as the label
        ),


        body: _isFetchingLocation
       ? const Center(child: CircularProgressIndicator(),)
        : Form( // Wrap your Column with a Form widget
          key: _formKey,
          child: SingleChildScrollView( // Use SingleChildScrollView to avoid overflow when keyboard appears
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedOption,
                            hint: const Text("Type of Obstacle"),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedOption = newValue;
                                if (_selectedOption != 'Other') {
                                  _customObstacleType = null; // Reset custom type if "Other" is not selected
                                }
                              });
                            },

                            items: _options.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            isExpanded: true,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedOption == 'Other') // Show this when 'Other' is selected
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Custom Obstacle Type',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _customObstacleType = value;
                              });
                            },
                          ),
                        ),
                      ),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                  child: Center(child:
                    Text(
                      'Prediction: $_prediction'

                    )
                    ),
                      ),
                    ),


                  ],
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Obstacle Photo',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,

                      decoration: BoxDecoration(
                          image: DecorationImage(image: FileImage(widget.image!), fit: BoxFit.cover)
                      ),
                    )
                  ],
                ),
               Row(
                 children: [
                   Expanded
                     (child: MapSample(newItem.lat, newItem.long)),
                 ],
               ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}