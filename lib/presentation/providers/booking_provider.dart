import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siankes/services/firestore_service.dart';
import 'package:siankes/data/models/booking_model.dart';
import 'package:siankes/data/models/doctor_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<BookingModel> _bookings = [];
  List<BookingModel> _adminBookings = [];
  List<DoctorModel> _doctors = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get adminBookings => _adminBookings;
  List<DoctorModel> get doctors => _doctors;
  bool get isLoading => _isLoading;

  StreamSubscription? _bookingSub;
  StreamSubscription? _doctorSub;

  void initStreams(String userId) {
    _doctorSub?.cancel();
    _doctorSub = _service.doctorsStream().listen((data) {
      _doctors = data;
      notifyListeners();
    });

    _bookingSub?.cancel();
    _bookingSub = _service.userBookingsStream(userId).listen((data) {
      _bookings = data;
      notifyListeners();
    });
  }

  void adminInitStreams() {
    _bookingSub?.cancel();
    _bookingSub = _service.allBookingsStream().listen((data) {
      _adminBookings = data;
      notifyListeners();
    });
  }

  List<DoctorModel> getDoctorsByPoli(String poliId) =>
      _doctors.where((d) => d.poliId == poliId).toList();

  Future<BookingModel> createBooking({
    required String userId, required String userName,
    required String doctorId, required String doctorName,
    required String poliId, required String poliName,
    required DateTime bookingDate, required String timeSlot,
    String complaint = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final booking = await _service.createBooking(
        userId: userId, userName: userName,
        doctorId: doctorId, doctorName: doctorName,
        poliId: poliId, poliName: poliName,
        bookingDate: bookingDate, timeSlot: timeSlot,
        complaint: complaint,
      );
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelBooking(String id) async {
    await _service.cancelBooking(id);
  }

  List<BookingModel> get upcomingBookings =>
      _bookings.where((b) => b.isPending || b.isConfirmed).toList();

  Future<void> confirmBooking(String id) async {
    await _service.confirmBooking(id);
  }

  Future<void> completeBooking(String id) async {
    await _service.completeBooking(id);
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    _doctorSub?.cancel();
    super.dispose();
  }
}
