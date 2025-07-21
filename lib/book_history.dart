import 'package:flutter/material.dart';

class BookHistoryPage extends StatelessWidget {
  const BookHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book History"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Book History Page"),
      ),
    );
  }
}
