import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/driver_entity.dart';

class DriverItem extends StatelessWidget {
  /// The driver to display
  final DriverEntity driver;

  const DriverItem({
    super.key,
    required this.driver,
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
                        driver.name,
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
                      label: Text(driver.rating?.toString() ?? 'N/A'),
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
            Text('${driver.vehicleInfo.model} (${driver.vehicleInfo.color})'),
            ElevatedButton.icon(
              onPressed: () {
                // Launch phone call
                final phoneNumber = driver.phoneNumber;
                // You would typically use url_launcher package to make a phone call
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appel à $phoneNumber'),
                  ),
                );
              },
              icon: Icon(Icons.phone),
              label: Text('Contacter'),
            ),
          ],
        )
      ],
    );
  }
}
