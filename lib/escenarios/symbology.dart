import 'package:flutter/material.dart';

class Symbology extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CardSymbology(imagePath: 'assets/img3.png', label: 'Available'),
          SizedBox(width: 20),
          CardSymbology(imagePath: 'assets/img1.png', label: 'Selected'),
          SizedBox(width: 20),
          CardSymbology(imagePath: 'assets/img2.png', label: 'Not available'),
        ],
      ),
    );
  }
}

class CardSymbology extends StatelessWidget {
  final String imagePath;
  final String label;

  const CardSymbology({
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 35,
          height: 35,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
