# 📚 RFID-Based Library Management System

An **Automated Library Management System** using **RFID**, **Raspberry Pi Pico**, **Firebase**, and a **Flutter mobile application** to streamline book issuing, returning, and user management. Designed to reduce human intervention, eliminate manual errors, and enhance accessibility with real-time features.

---

## 📌 Features

- 🔐 **RFID Authentication** for students and books
- ⏱️ **Real-time database** synchronization via Firebase
- 📲 **Mobile app** (Flutter) for students to:
  - View issued books
  - Search library catalog
  - Receive due date notifications
  - View and pay fines
  - Track borrowing history
- 🔄 **Automated book issuance and return**
- 💸 Fine calculation and reminders
- 🛡️ Role-based access control (Student/Librarian)
- 📡 IoT-based, scalable design

---

## 🛠️ Tech Stack

| Component       | Technology            |
|----------------|------------------------|
| Microcontroller| Raspberry Pi Pico      |
| RFID Reader    | MFRC522                |
| Database       | Firebase Realtime DB   |
| Mobile App     | Flutter (Dart)         |
| Backend Logic  | C++/Python (for Pi)    |

---

## 🧠 System Architecture


---

## 🚀 How It Works

### 👤 Student Authentication
- Student scans RFID card
- Student details fetched from Firebase
- Access granted if valid

### 📘 Book Issuance
- Scan book RFID tag
- If available, book is issued and Firebase is updated
- Issue date and book details shown in mobile app

### 📙 Book Return & Fine
- Scan book tag
- Fine calculated based on due date
- Status updated in real time
- Fine shown in app, payment possible

---

## 📱 Mobile App Screens (Flutter)

- **Login / Sign-Up**
- **Profile Dashboard**
- **Issued Books List**
- **Search Book by Title/Author**
- **Pay Fine**
- **Borrowing History**
- **Forgot Password**

---

## 📈 Future Enhancements

- 🤖 AI-based book recommendations
- 📚 Digital resource integration (e-books, journals)
- 🤝 RFID integration with campus services (payments, entry)
- 🎯 Gamification for reading goals
- 🛰️ Advanced book location tracking within library

---

## 👨‍💻 Authors

- Ashvini Barbadekar (Mentor) – ashwini.barbadekar@vit.edu  
- Priyanshu Dambhare – priyanshu.dambhare23@vit.edu  
- Aditya Walsepatil – aditya.walsepatilpatil22@vit.edu  
- **Shailesh Waghmode** – shailesh.waghmode22@vit.edu  
- Yash Telkhade – yash.telkhade22@vit.edu  

---

## 📃 References

See detailed references in the [project report](./ESD_CP_Report_modified.pdf) including IEEE papers related to RFID, IoT, and library automation.

---

## 📸 Screenshots

> *(Will be added soon)*

---

## 📂 Project Structure

