import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void _addItem() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => NewItem()));

    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
      'shopping-list-57633-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list.json',
    );
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;

      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );

      setState(() {
        _groceryItems = _loadedItems;
      });
    }
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(context) {
    final content = Container(
      alignment: Alignment.center,
      child: Text('No items here.. Start adding new items!'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: _groceryItems.isNotEmpty
          ? ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.rectangle,
                    color: _groceryItems[index].category.color,
                  ),
                  title: Text(_groceryItems[index].name),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ),
            )
          : content,
    );
  }
}
