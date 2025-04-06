import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';

class DriverItem extends StatelessWidget {
  /// The driver to display
  final UserEntity driver;

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        driver.fullName,
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
                      label: Text(
                          driver.driverDetails?.rating?.toString() ?? 'N/A'),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
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
            Text(driver.driverDetails?.primaryVehicle != null
                ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                : 'Unknown vehicle'),
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
