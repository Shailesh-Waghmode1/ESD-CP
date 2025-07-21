const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.onBookIssued = onDocumentCreated(
    "Realtime_database/{docId}",
    async (event) => {
      const data = event.data && event.data.data();
      if (!data) {
        console.log("No data found in document.");
        return;
      }

      const bookRfid = data.book_rfid;
      if (!bookRfid) {
        console.log("No book_rfid found in document.");
        return;
      }

      const issueDate = new Date();
      const returnDate = new Date(issueDate);
      returnDate.setDate(issueDate.getDate() + 10);

      // Update the corresponding book in Book_store
      const bookQuery = await db.collection("Book_store")
          .where("book_rfid", "==", bookRfid)
          .get();

      if (!bookQuery.empty) {
        const bookDoc = bookQuery.docs[0];
        await bookDoc.ref.update({
          issue_date: issueDate.toISOString(),
          return_date: returnDate.toISOString(),
          status: true,
        });
        console.log(`Book_store updated for book_rfid: ${bookRfid}`);
      } else {
        console.log(`Book with RFID ${bookRfid} not found in Book_store`);
      }

      // Update the Realtime_database document with issue_date
      await db.collection("Realtime_database").doc(event.params.docId).update({
        issue_date: issueDate.toISOString(),
      });

      console.log(`Realtime_database updated for docId: ${event.params.docId}`);
    },
);
