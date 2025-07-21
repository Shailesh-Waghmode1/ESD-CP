import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IssuedBooksScreen extends StatefulWidget {
  const IssuedBooksScreen({super.key});

  @override
  State<IssuedBooksScreen> createState() => _IssuedBooksScreenState();
}

class _IssuedBooksScreenState extends State<IssuedBooksScreen> {
  List<Map<String, dynamic>> issuedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIssuedBooks();
  }

  Future<void> fetchIssuedBooks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get student_rfid using UID
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('Students_data')
          .doc(user.uid)
          .get();

      final studentData = studentSnapshot.data();
      final studentRfid = studentData?['student_rfid'];

      if (studentRfid == null) return;

      // Search Realtime_database for entries with matching student_rfid
      final realtimeSnapshot =
      await FirebaseFirestore.instance.collection('Realtime_database').get();

      final matchingEntries = realtimeSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['student_rfid'] == studentRfid;
      });

      List<Map<String, dynamic>> results = [];

      for (var entry in matchingEntries) {
        final bookRfid = entry['book_rfid'];

        // Fetch book details from Book_store
        final bookSnapshot = await FirebaseFirestore.instance
            .collection('Book_store')
            .where('book_rfid', isEqualTo: bookRfid)
            .get();

        if (bookSnapshot.docs.isNotEmpty) {
          final bookData = bookSnapshot.docs.first.data();

          // Calculate expected return date (10 days from issue_date)
          final issueDateStr = bookData['issue_date'] ?? '';
          DateTime? issueDate;
          DateTime? expectedReturnDate;
          int fine = 0;
          DateTime? returnDate;

          try {
            issueDate = DateTime.parse(issueDateStr);
            expectedReturnDate = issueDate.add(const Duration(days: 10));

            final returnDateStr = bookData['return_date'];
            if (returnDateStr != null) {
              try {
                returnDate = DateTime.parse(returnDateStr);
              } catch (_) {
                returnDate = null;
              }
            }

            final currentDate = DateTime.now();
            DateTime compareDate;

            // If return date is available, calculate fine based on return date
            if (returnDate != null) {
              compareDate = returnDate;
            } else {
              compareDate = currentDate; // Use current date if return date is null
            }

            final daysPassed = compareDate.difference(issueDate).inDays;

            // Fine is applicable after 10 days of grace period
            if (daysPassed > 10) {
              fine = (daysPassed - 10) * 5; // ₹5 per day after 10 days
            }
          } catch (_) {}

          results.add({
            'name': bookData['name'],
            'book_rfid': bookRfid,
            'issue_date': issueDateStr,
            'expected_return': expectedReturnDate?.toIso8601String() ?? 'Invalid Date',
            'return_date': returnDate?.toIso8601String() ?? 'Not Returned',
            'applicable_fine': fine,
          });
        }
      }

      setState(() {
        issuedBooks = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching issued books: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : issuedBooks.isEmpty
          ? const Center(child: Text("No books issued"))
          : ListView.builder(
        itemCount: issuedBooks.length,
        itemBuilder: (context, index) {
          final book = issuedBooks[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(book['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Book RFID: ${book['book_rfid']}"),
                  Text("Issued on: ${book['issue_date']}"),
                  Text("Expected Return by: ${book['expected_return']}"),
                  if (book['return_date'] != 'Not Returned')
                    Text("Returned on: ${book['return_date']}"),
                  Text("Fine: ₹${book['applicable_fine']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
