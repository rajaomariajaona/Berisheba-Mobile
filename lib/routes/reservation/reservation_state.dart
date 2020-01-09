import 'package:flutter/material.dart';

class ReservationState extends ChangeNotifier {
  bool _isDeletingReservation = false;

  bool get isDeletingReservation => _isDeletingReservation;

  set isDeletingReservation(bool value) {
    _isDeletingReservation = value;
  }
}
