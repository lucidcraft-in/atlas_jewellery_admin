import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'banner/bannerScreen.dart';
import 'termsAndCondition/showTermsAndCond.dart';

class Sliderpage extends StatefulWidget {
  const Sliderpage({super.key});

  @override
  State<Sliderpage> createState() => _SliderpageState();
}

class _SliderpageState extends State<Sliderpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Sliders"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * .2,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .11,
                          child: IconButton(
                              icon: FaIcon(FontAwesomeIcons.noteSticky,
                                  size: 32, color: useColor.homeIconColor),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BannerScreen()));
                              })),
                      Text(
                        "Banner",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .11,
                          child: IconButton(
                              icon: FaIcon(FontAwesomeIcons.notdef,
                                  size: 32, color: useColor.homeIconColor),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TermsAndCondition()));
                              })),
                      Text(
                        "T & C",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
