# 🏥 SIANKES - Sistem Informasi Antrian Klinik

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Aplikasi Mobile Healthcare Modern untuk Manajemen Antrian Klinik**  
*Terinspirasi dari UI/UX Mobile JKN BPJS Kesehatan*

</div>

---

## 📋 Deskripsi

SIANKES adalah aplikasi mobile sistem informasi antrian klinik berbasis **Flutter + Firebase** yang dirancang untuk memberikan pengalaman pengguna setara aplikasi healthcare premium. Aplikasi ini mendukung manajemen antrian realtime, booking jadwal dokter, QR code check-in, dan push notification.

## ✨ Fitur Utama

### 🔐 Authentication
- Login & Register dengan Firebase Auth
- Forgot Password (email reset)
- Session management otomatis
- Role-based access (User & Admin)

### 🏠 Dashboard Pasien
- Profil pasien dengan statistik
- Nomor antrian aktif (realtime)
- Status antrian live
- Jadwal booking terdekat
- Shortcut menu layanan
- Informasi kesehatan

### 📱 Sistem Antrian Realtime
- Ambil nomor antrian online
- Pilih poli & dokter
- Generate nomor otomatis
- **Tracking realtime** via Firebase Firestore
- Status: Menunggu → Dipanggil → Selesai
- Auto refresh tanpa manual reload
- Progress indicator visual

### 📅 Booking Jadwal Dokter
- Pilih dokter berdasarkan poli
- Pilih tanggal & jam
- Konfirmasi booking
- Riwayat booking lengkap

### 🔔 Push Notification
- Notifikasi antrian hampir dipanggil
- Notifikasi giliran tiba
- Reminder booking
- Swipe-to-delete & mark-as-read
- Badge counter realtime

### 📊 Riwayat Pasien
- Histori antrian (dengan detail)
- Histori booking (dengan detail)
- Timeline pelayanan
- Status pelayanan visual

### 👤 Profile Management
- Edit profil lengkap
- Statistik penggunaan
- Upload foto profil
- Ubah password

### 🔲 QR Code System
- Generate QR Code untuk antrian
- QR digunakan saat check-in
- Detail antrian tersimpan di QR

### 🛠️ Admin Features
- Dashboard admin dengan statistik
- Kelola antrian per poli
- Tombol panggil antrian berikutnya
- Skip & reset antrian
- Trigger notifikasi otomatis ke pasien
- Scan QR Code

---

## 🏗️ Arsitektur Project

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Konstanta aplikasi
│   ├── theme/
│   │   ├── app_colors.dart             # Sistem warna healthcare
│   │   └── app_theme.dart              # Material Design 3 theme
│   └── utils/
│       ├── date_formatter.dart         # Format tanggal Indonesia
│       └── validators.dart             # Form validation
├── data/
│   └── models/
│       ├── user_model.dart             # Model user/pasien
│       ├── queue_model.dart            # Model antrian
│       ├── doctor_model.dart           # Model dokter & poli
│       ├── booking_model.dart          # Model booking
│       └── notification_model.dart     # Model notifikasi
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart          # State auth
│   │   ├── queue_provider.dart         # State antrian realtime
│   │   ├── booking_provider.dart       # State booking
│   │   └── notification_provider.dart  # State notifikasi
│   ├── screens/
│   │   ├── splash/                     # Splash screen
│   │   ├── onboarding/                 # Onboarding 3 halaman
│   │   ├── auth/                       # Login, Register, Forgot Password
│   │   ├── home/                       # Dashboard, Queue, History, Profile tabs
│   │   ├── queue/                      # Take Queue, Queue Status
│   │   ├── booking/                    # Booking jadwal
│   │   ├── doctor/                     # Daftar dokter + search
│   │   ├── polyclinic/                 # Daftar poli
│   │   ├── history/                    # Detail riwayat
│   │   ├── profile/                    # Edit profil
│   │   ├── admin/                      # Dashboard admin
│   │   ├── notifications/              # Notifikasi
│   │   └── qr/                         # Scan QR
│   └── widgets/
│       └── shared_widgets.dart         # Reusable widgets
├── services/
│   ├── auth_service.dart               # Firebase Auth service
│   ├── firestore_service.dart          # Firestore CRUD operations
│   └── notification_service.dart       # Notification management
├── routes/
│   └── app_router.dart                 # Route management
├── firebase_options.dart               # Firebase config
└── main.dart                           # Entry point
```

---

## 🛠️ Teknologi

| Kategori | Teknologi |
|----------|-----------|
| **Frontend** | Flutter (latest) |
| **Backend** | Firebase |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore (realtime) |
| **Storage** | Firebase Storage |
| **Messaging** | Firebase Cloud Messaging |
| **State Management** | Provider |
| **UI Framework** | Material Design 3 |
| **Font** | Plus Jakarta Sans (Google Fonts) |

---

## 🗂️ Firestore Collections

| Collection | Deskripsi |
|------------|-----------|
| `users` | Data profil pengguna |
| `queues` | Data antrian (realtime) |
| `bookings` | Data booking jadwal |
| `doctors` | Data dokter |
| `polyclinics` | Data poli klinik |
| `notifications` | Data notifikasi |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK ^3.5.0
- Dart SDK ^3.5.0
- Firebase project (sudah dikonfigurasi)
- Android Studio / VS Code

### Langkah-langkah

```bash
# 1. Clone repository
git clone https://github.com/username/siankes.git
cd siankes

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run

# 4. Build APK (opsional)
flutter build apk --release
```

### Konfigurasi Firebase
1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Tambahkan aplikasi Android/iOS
3. Download `google-services.json` / `GoogleService-Info.plist`
4. Atau gunakan FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 📱 Daftar Screen

| # | Screen | Deskripsi |
|---|--------|-----------|
| 1 | Splash Screen | Logo animasi + auto navigation |
| 2 | Onboarding | 3 halaman perkenalan fitur |
| 3 | Login | Form login + quick admin demo |
| 4 | Register | Form registrasi lengkap |
| 5 | Forgot Password | Reset password via email |
| 6 | Home Dashboard | Dashboard informatif + shortcut |
| 7 | Daftar Poli | List poli dengan statistik |
| 8 | Daftar Dokter | Search + filter dokter |
| 9 | Ambil Antrian | Pilih poli, dokter, keluhan |
| 10 | Status Antrian | Tracking realtime + QR |
| 11 | Booking Jadwal | Reservasi dokter |
| 12 | Riwayat | Tab antrian + booking |
| 13 | Detail Riwayat | Timeline + QR code |
| 14 | Profile | Statistik + menu |
| 15 | Edit Profile | Form edit data diri |
| 16 | Admin Dashboard | Kelola antrian + panggil |
| 17 | Notifikasi | List notifikasi + swipe |
| 18 | Scan QR | QR code scanner |

---

## 🎨 Design System

- **Warna Primer**: Biru (#1565C0) - Healthcare professional
- **Gradient**: Biru gelap ke biru terang
- **Tipografi**: Plus Jakarta Sans (modern, clean)
- **Komponen**: Card-based layout, rounded corners (16-28px)
- **Animasi**: FadeIn, SlideIn, scale transitions
- **Loading**: Shimmer effect
- **Shadow**: Soft shadow (0.04-0.08 opacity)

---

## 👥 Akun Demo

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@siankes.com | admin123 |
| User | (daftar baru) | - |

---

## 📄 Lisensi

Project ini dibuat sebagai **Final Project Mata Kuliah Pemrograman Mobile**.

---

<div align="center">
  <b>SIANKES v2.0.0</b> • Flutter + Firebase • Healthcare Mobile App
</div>
