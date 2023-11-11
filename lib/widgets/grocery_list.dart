import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list_app/data/categories.dart';

import 'package:shoping_list_app/models/grocery_item.dart';
import 'package:shoping_list_app/widgets/new_grocery.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-fcc40-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'There was a problem in fetching the data, try again later.';
      });
    }

    final Map<String, dynamic> myItems = json.decode(response.body);
    List<GroceryItem> loadedItems = [];

    for (final item in myItems.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewGroceryItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removingItem(GroceryItem item) {
    final url = Uri.https('flutter-prep-fcc40-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    http.delete(url);
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
        child: Text(
      'No items available, Try adding some.',
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    ));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removingItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = content = Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
            child: Text(
          _error!,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
