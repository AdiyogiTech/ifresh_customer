import 'package:flutter/material.dart';
import 'package:iFresh_customer/helper_widget/sized_box.dart';
import 'package:iFresh_customer/screens/constant/colors.dart';

class AuthBackground extends StatelessWidget {
  final String labelname;
  final Widget childs;
  final double? space;

  const AuthBackground({
    super.key,
    required this.labelname,
    required this.childs,
     this.space,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          // Background Image
          Image.asset(
            "assets/images/loginBackground.png",
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
          ),


          // Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.08,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "assets/images/iFresh.png",
                    scale: 4.5,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: space ??  size.height * 0.09),

                  // Card Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: size.width * 0.075,
                    horizontal: size.width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.20),
                          offset: const Offset(3, 3),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          labelname.toUpperCase(),
                          style: TextStyle(
                            color: primarylogin,
                            fontSize: size.width * 0.065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: size.height * 0.025),

                        // Child Widget
                        childs,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

