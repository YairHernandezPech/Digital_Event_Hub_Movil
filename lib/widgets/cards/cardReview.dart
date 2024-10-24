import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String username;
  final String img;
  final String text;
  final String fecha;

  // Constructor
  ReviewCard(
      this.username, this.img, this.text, this.fecha);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(img),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              fecha,
              style: TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 173, 173, 173),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}