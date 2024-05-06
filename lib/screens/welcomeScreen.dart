import 'package:flutter/material.dart';
import 'package:ptyxiaki/screens/mainscreen.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  @override
  Widget build(BuildContext context) {
    List<String> firstString= ['Welcome!', 'App fucntionality', 'What to do'];
    List<String> secondString = ['The aim of this app is to enable pedestrians to report any obstacles they encounter to the authorities, which will hopefully increase pedestrian safety by allowing the authorites to deal with the obstruction more quickly',
    'Computer vision algorithms are emplyed to make reporting the obstacles type faster. Other relevant details about the obstacles are automatically gathered using the device\'s available sensors, requiring minimal user interaction.',
      'Click the Camera Icon -> Click the Take a new picture button -> Take a picture -> Select the type of obstacle with the help of prediction -> Click the Add Item button'
    ];
    List<Color> color= [Colors.purple, Colors.blue, Colors.orange];
    List<String> images = ['assets/images/welcomePageImages/image0.png', 'assets/images/welcomePageImages/image1.png', 'assets/images/welcomePageImages/image2.png'];
    return Scaffold(

body: PageView.builder(itemCount:3,
  itemBuilder:(context, index){
  return Container(
    color: color[index],
    child:  Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(firstString[index], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                      ),
            ),

          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            index==2 ? GestureDetector( onTap: (){
              // Navigate to MainScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
              child:
                Container(
                  margin: const EdgeInsets.only(top: 80),
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(images[index]),
                      // You can change this to fit your needs
                    ),
                  ),
                )
             )
            : Container(
              margin:const EdgeInsets.only(top: 80),
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(images[index]),
                   // You can change this to fit your needs
                ),
              ),
            )

          ],

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text(
                  secondString[index],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center, // This ensures the text itself is centered if it wraps to a new line.
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(

          children: [
            const SizedBox(width: 50,),
            ...List.generate(3, (indexList) { // Use the spread operator to expand the list
              return Padding(
                padding: EdgeInsets.only(left: indexList == 0 ? 100 : 5, bottom: 20), // Apply left padding only to the first item
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200), // Adjusted duration for visibility
                  width: index == indexList ? 50 : 20,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index == indexList
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ],
        )


      ],
    ),
       );
}, ),
    );
  }
}
