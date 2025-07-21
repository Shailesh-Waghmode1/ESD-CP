import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBookPage extends StatefulWidget {
  const SearchBookPage({super.key});

  @override
  State<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends State<SearchBookPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void _searchBooks(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Book_store')
        .where('status', isEqualTo: false) // Query books with status as false (available)
        .get();

    List<Map<String, dynamic>> results = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name']?.toString().toLowerCase() ?? '';

      // Check if the book name matches the query
      if (name.contains(query.toLowerCase())) {
        results.add(data);
      }
    }

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Available Books"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar for book names
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter book name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchBooks(_controller.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                _searchBooks(value);
              },
            ),
            const SizedBox(height: 20),
            // Display search results
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(child: Text("No books found"))
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final book = searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(book['name'] ?? "No Name"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Book RFID: ${book['book_rfid']}"),
                          Text("Status: ${book['status'] == false ? "Available" : "Issued"}"),
                          Text("Issue Date: ${book['issue_date']}"),
                          Text("Return Date: ${book['return_date']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
