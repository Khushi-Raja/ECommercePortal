import 'package:flutter/cupertino.dart';
import 'package:link/constants/color.dart';

// Custom widget to display a CupertinoActivityIndicator
class CustomCupertinoActivityIndicator extends StatelessWidget {
  // You can add parameters to customize the size and animating property of the activity indicator
  final double? size; // Size of the activity indicator (height and width)
  final bool animating; // Whether the activity indicator is animating

  const CustomCupertinoActivityIndicator({
    super.key,
    this.size = 30.0,     // Default size is 30.0
    this.animating = true, // Default is animating
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,  // Set the height of the CupertinoActivityIndicator
      width: size,   // Set the width of the CupertinoActivityIndicator
      child: CupertinoActivityIndicator(
        radius: size! / 2, // The radius for the activity indicator
        animating: animating, // Whether it's animating
        color: kAppBarColor, // Color of the activity indicator
      ),
    );
  }
}