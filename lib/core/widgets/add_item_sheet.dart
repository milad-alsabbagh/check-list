import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stamina_check_list/core/constants.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // handles keyboard
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            TextField(
              controller: itemController,
              decoration: const InputDecoration(labelText: 'Item'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String item = itemController.text;
                String category = categoryController.text;
                print(category == "");
                log(item);

                if (item != "") {
                  _firestore.collection(kCheckList).add({
                    kItemNameField: item,
                    kCategoryField: category,
                    kTimestampField: FieldValue.serverTimestamp(),
                    kCheckingField: false,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
