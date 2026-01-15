import 'package:flutter/foundation.dart';
import '../data/models/doctor_model.dart';
import '../data/repositories/doctor_repository.dart';

class ConsultViewModel extends ChangeNotifier {
  final DoctorRepository _doctorRepository;
  String _searchQuery = '';
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  ConsultViewModel({required DoctorRepository doctorRepository})
      : _doctorRepository = doctorRepository {
    _initDoctorsListener();
  }

  // Getters
  List<Doctor> get doctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void _initDoctorsListener() {
    _doctorRepository.getDoctorsStream().listen(
      (doctors) {
        _allDoctors = doctors;
        _isLoading = false;
        _filterDoctors(); // Apply current filter
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void search(String query) {
    _searchQuery = query;
    _filterDoctors();
    notifyListeners();
  }

  void _filterDoctors() {
    if (_searchQuery.isEmpty) {
      _filteredDoctors = List.from(_allDoctors);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
      }).toList();
    }
  }
}
