import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'issued_books_screen.dart';
import 'book_history.dart';
import 'pay_fine.dart';
import 'search_book.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String studentName = "";
  int studentPrn = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
  }

  void fetchStudentInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Students_data')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          studentName = doc['name'] ?? "";
          studentPrn = doc['prn'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          studentName = "Unknown";
          studentPrn = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching student info: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Student Info Widget (Row 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Student Name and PRN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: $studentName",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "PRN: $studentPrn",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Student Photo
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // First row: Issued_books & Book_History
            Row(
              children: [
                buildMenuCard("Issued Books", Icons.library_books, const IssuedBooksScreen()),
                buildMenuCard("Book_History", Icons.history, const BookHistoryPage()),
              ],
            ),
            const SizedBox(height: 16),

            // Second row: Pay Fine & Search Book
            Row(
              children: [
                buildMenuCard("Pay Fine", Icons.payment, const PayFinePage()),
                buildMenuCard("Search Book", Icons.search, const SearchBookPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Menu card builder with navigation
  Widget buildMenuCard(String title, IconData icon, Widget page) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
