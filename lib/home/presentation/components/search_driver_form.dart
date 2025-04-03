import 'package:flutter/material.dart';

class SearchDriverForm extends StatelessWidget {
  const SearchDriverForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              Text(
                'Où allez-vous ?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Entrez votre destination',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.my_location,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Ma position actuelle'),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: Text('Trouver un taxi-moto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
