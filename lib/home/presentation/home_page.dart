import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/search_driver_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              spacing: 4.0,
              children: [
                Icon(Icons.location_on),
                Text('Sabotsy Namehana'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: const SearchDriverForm(),
          ),
          // Available drivers list
          const AvailableDriversList(),
        ],
      ),
    );
  }
}
