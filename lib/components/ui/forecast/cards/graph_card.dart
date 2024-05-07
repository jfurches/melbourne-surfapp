import 'package:flutter/material.dart';

class GraphCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconColor;
  final Widget graph;

  const GraphCard({
    super.key,
    required this.title,
    required this.iconData,
    this.iconColor = Colors.black,
    required this.graph,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              // Wrap icon and title in a separate Row
              children: [
                Icon(
                  iconData,
                  size: 30,
                  color: iconColor,
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: graph),
          ],
        ),
      ),
    );
  }
}
