import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventCali extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster image
        Container(
          width: 100,
          height: 110,
          margin: EdgeInsets.only(right: 10),
          child: Image.asset(
            'assets/eventolocal.png',
            fit: BoxFit.cover,
          ),
        ),
        
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blue Man Group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Rating and reviews
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.purple,
                  size: 24.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  '4.5',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              '45 reseñas totales',
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF2F2E2E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }
}
