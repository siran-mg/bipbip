import 'package:flutter/material.dart';

class DriverItem extends StatelessWidget {
  const DriverItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16.0,
              children: [
                CircleAvatar(
                  radius: 24.0,
                  child: Image.network(
                    'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.0,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Jean Dupont',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text('5.0'),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4.0,
              children: [
                Text('5 km'),
                Text('15 min'),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Yamaha G5'),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.phone),
              label: Text('Contacter'),
            ),
          ],
        )
      ],
    );
  }
}
