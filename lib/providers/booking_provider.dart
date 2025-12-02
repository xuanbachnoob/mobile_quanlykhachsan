import 'package:flutter/material.dart';
import '../models/phongandloaiphong.dart';
import '../models/dichvu.dart';

/// Provider quản lý booking
class BookingProvider extends ChangeNotifier {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 2;
  List<Phongandloaiphong> _selectedRooms = [];
  List<SelectedDichVu> _selectedServices = [];

  // Getters
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;
  int get guestCount => _guestCount;
  List<Phongandloaiphong> get selectedRooms => _selectedRooms;
  List<SelectedDichVu> get selectedServices => _selectedServices;

  int get numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) return 1;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get roomsTotal {
  return selectedRooms.fold<double>(
    0,
    (sum, room) => sum + room.giaSauGiam * numberOfNights,
  );
}

  double get servicesTotal {
    return _selectedServices.fold(
      0,
      (sum, service) => sum + service.tongGia,
    );
  }

  double get grandTotal => roomsTotal + servicesTotal;

  // Methods
  void setSearchCriteria(DateTime checkIn, DateTime checkOut, int guests) {
    _checkInDate = checkIn;
    _checkOutDate = checkOut;
    _guestCount = guests;
    notifyListeners();
  }

  void setSelectedRooms(List<Phongandloaiphong> rooms) {
    _selectedRooms = rooms;
    notifyListeners();
  }

  void addService(DichVu service) {
    final existingIndex = _selectedServices.indexWhere(
      (s) => s.dichvu.madv == service.madv, 
    );

    if (existingIndex >= 0) {
      _selectedServices[existingIndex].soluong++;
    } else {
      _selectedServices.add(SelectedDichVu(dichvu: service));
    }
    notifyListeners();
  }

  void removeService(int madv) {
    _selectedServices.removeWhere((s) => s.dichvu.madv == madv); 
    notifyListeners();
  }

  void updateServiceQuantity(int madv, int quantity) {
    final index = _selectedServices.indexWhere(
      (s) => s.dichvu.madv == madv, 
    );
    if (index >= 0) {
      if (quantity > 0) {
        _selectedServices[index].soluong = quantity;
      } else {
        _selectedServices.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearServices() {
    _selectedServices.clear();
    notifyListeners();
  }

  void clearAll() {
    _checkInDate = null;
    _checkOutDate = null;
    _guestCount = 2;
    _selectedRooms = [];
    _selectedServices = [];
    notifyListeners();
  }
}