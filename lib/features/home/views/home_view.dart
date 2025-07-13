import 'package:flutter/material.dart';
import 'package:stamina_check_list/features/checking_list/views/checking_list_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CheckListView());
  }
}
