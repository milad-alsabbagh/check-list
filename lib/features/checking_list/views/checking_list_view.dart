import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stamina_check_list/core/constants.dart';
import 'package:stamina_check_list/core/widgets/add_item_sheet.dart';

class CheckListView extends StatelessWidget {
  CheckListView({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to reset all checking fields to false
  Future<void> _resetAllChecking() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(kCheckList).get();
      for (DocumentSnapshot doc in snapshot.docs) {
        await _firestore.collection(kCheckList).doc(doc.id).set({
          'checking': false,
        }, SetOptions(merge: true));
      }
      log('All checking fields reset to false.');
    } catch (e) {
      log('Error resetting checking fields: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream:
          null, // This outer StreamBuilder seems redundant and can be removed.
      builder: (context, snapshot) {
        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection(kCheckList)
                    .orderBy(kCategoryField)
                    .snapshots(), // The stream of data
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                log('${snapshot.data}');
                return const Center(child: Text('No items found.'));
              }

              // Data is available, build the list
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(
                                data[kItemNameField] == ""
                                    ? 'No Name'
                                    : data[kItemNameField],
                              ),
                              subtitle: Text(
                                data[kCategoryField] == ""
                                    ? 'No category'
                                    : data[kCategoryField],
                              ), // Assuming 'name' field
                              trailing: Checkbox(
                                value:
                                    document[kCheckingField] ??
                                    false, // Get the current value from Firestore, default to false
                                onChanged: (bool? newValue) async {
                                  if (newValue != null) {
                                    await _firestore
                                        .collection(kCheckList)
                                        .doc(document.id)
                                        .set(
                                          {kCheckingField: newValue},
                                          SetOptions(merge: true),
                                        ); // Use set with merge: true
                                  }
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetAllChecking, // Call the new function

                    child: const Text('Reset', style: TextStyle(fontSize: 18)),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // makes the sheet expand nicely
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return const AddItemSheet();
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
