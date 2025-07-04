// lib/utils/validators.dart

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    return null;
  }

  static String? validateSport(String? value) {
    if (value == null || value.isEmpty) return 'Sport is required';
    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) return 'Time is required';
    return null;
  }

  static String? validatePaidStatus(String? value) {
    if (value == null || value.isEmpty) return 'Paid/Unpaid status is required';
    return null;
  }

  static String? validateGroupName(String? value) {
    if (value == null || value.isEmpty) return 'Group name is required';
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Date is required';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Description is required';
    return null;
  }

  static String? validateAgeRange(String? value) {
    if (value == null || value.isEmpty) return 'Age range is required';
    return null;
  }

  static String? validateVenue(String? value) {
    if (value == null || value.isEmpty) return 'Venue is required';
    return null;
  }
}