import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PayFinePage extends StatefulWidget {
  const PayFinePage({super.key});

  @override
  State<PayFinePage> createState() => _PayFinePageState();
}

class _PayFinePageState extends State<PayFinePage> {
  List<Map<String, dynamic>> finedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFineDetails();
  }

  Future<void> fetchFineDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final studentSnapshot = await FirebaseFirestore.instance
          .collection('Students_data')
          .doc(user.uid)
          .get();

      final studentData = studentSnapshot.data();
      final studentRfid = studentData?['student_rfid'];

      if (studentRfid == null) return;

      final realtimeSnapshot =
      await FirebaseFirestore.instance.collection('Realtime_database').get();

      final matchingEntries = realtimeSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['student_rfid'] == studentRfid;
      });

      List<Map<String, dynamic>> results = [];

      for (var entry in matchingEntries) {
        final bookRfid = entry['book_rfid'];

        final bookSnapshot = await FirebaseFirestore.instance
            .collection('Book_store')
            .where('book_rfid', isEqualTo: bookRfid)
            .get();

        if (bookSnapshot.docs.isNotEmpty) {
          final bookData = bookSnapshot.docs.first.data();

          final issueDateStr = bookData['issue_date'] ?? '';
          DateTime? issueDate;
          DateTime? returnDate;
          int fine = 0;

          try {
            issueDate = DateTime.parse(issueDateStr);

            final returnDateStr = bookData['return_date'];
            if (returnDateStr != null) {
              returnDate = DateTime.tryParse(returnDateStr);
            }

            final compareDate = returnDate ?? DateTime.now();
            final daysPassed = compareDate.difference(issueDate).inDays;

            if (daysPassed > 10) {
              fine = (daysPassed - 10) * 5;
            }
          } catch (_) {}

          if (fine > 0) {
            results.add({
              'name': bookData['name'],
              'book_rfid': bookRfid,
              'fine': fine,
            });
          }
        }
      }

      setState(() {
        finedBooks = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fine details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showQRCodeDialog(String bookName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pay Fine for \"$bookName\""),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan this QR code to pay your fine"),
            const SizedBox(height: 16),
            Image.asset('images/qr_code.jpg', width: 200, height: 200),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Fine"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : finedBooks.isEmpty
          ? const Center(child: Text("No pending fines"))
          : ListView.builder(
        itemCount: finedBooks.length,
        itemBuilder: (context, index) {
          final book = finedBooks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(book['name'] ?? 'Unknown'),
              subtitle: Text("Fine: ₹${book['fine']}"),
              trailing: ElevatedButton(
                onPressed: () => showQRCodeDialog(book['name']),
                child: const Text("Pay Fine"),
              ),
            ),
          );
        },
      ),
    );
  }
}
