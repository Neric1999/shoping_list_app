import 'package:flutter/material.dart';
import 'package:shoping_list_app/data/dummy_items.dart';

class GroceriesScreen extends StatelessWidget {
  const GroceriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          for (final grocery in groceryItems)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    color: grocery.category.color,
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Text(grocery.name),
                  const Spacer(),
                  Text('${grocery.quantity}')
                ],
              ),
            ),
        ],
      ),
    );
  }
}
