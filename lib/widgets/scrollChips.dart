// import 'package:flutter/material.dart';

// class ScrollChips extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           FilterChip(
//             label: Container(
//               width: 70, // Ancho fijo
//               alignment: Alignment.center,
//               child: Text('Tecnología'),
//             ),
//             onSelected: (bool value) {},
//             backgroundColor: Theme.of(context).colorScheme.tertiary,
//             selectedColor: Color(0xFFD36AE4),
//             labelStyle: TextStyle(color: Colors.white),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
//           SizedBox(width: 10),
//           FilterChip(
//             label: Container(
//               width: 70, // Ancho fijo
//               alignment: Alignment.center,
//               child: Text('Deportes'),
//             ),
//             onSelected: (bool value) {},
//             backgroundColor: Theme.of(context).colorScheme.tertiary,
//             selectedColor: Color(0xFFD36AE4),
//             labelStyle: TextStyle(color: Colors.white),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
//           SizedBox(width: 10),
//           FilterChip(
//             label: Container(
//               width: 70, // Ancho fijo
//               alignment: Alignment.center,
//               child: Text('Cine'),
//             ),
//             onSelected: (bool value) {},
//             backgroundColor: Theme.of(context).colorScheme.tertiary,
//             selectedColor: Color(0xFFD36AE4),
//             labelStyle: TextStyle(color: Colors.white),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
//           SizedBox(width: 10),
//           FilterChip(
//             label: Container(
//               width: 70, // Ancho fijo
//               alignment: Alignment.center,
//               child: Text('Teatro'),
//             ),
//             onSelected: (bool value) {},
//             backgroundColor: Theme.of(context).colorScheme.tertiary,
//             selectedColor: Color(0xFFD36AE4),
//             labelStyle: TextStyle(color: Colors.white),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
          
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ScrollChips extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;
  final String selectedCategory;
  

  const ScrollChips({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: FilterChip(
              label: Text(category),
              onSelected: (bool selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              selected: selectedCategory == category,
              // selectedColor: Colors.amber,
              labelStyle: TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}