// lib/utils/validators.dart
class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name cannot exceed 30 characters';
    }
    if (value.contains(RegExp(r'\s{2,}'))) {
      return 'Name cannot contain consecutive spaces';
    }
    final RegExp nameRegExp = RegExp(r'^[a-zA-ZÀ-ÿ\u00f1\u00d1]+([ ][a-zA-ZÀ-ÿ\u00f1\u00d1]+)*$');
    
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and single spaces between words';
    }
    return null;
  }
  static String cleanName(String value) {
    String cleaned = value.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    if (cleaned.contains(RegExp(r'\s{2,}'))) {
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    }
    
    return cleaned;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    const validDomains = r'com|es|co|net|org|edu|gov|mil|int|biz|info|name|museum';

    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+(\.[a-zA-Z]+)*\.(' + validDomains + r')$'
    );

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }
    if (value.trim().length > 45) {
      return 'Email cannot exceed 45 characters';
    }

    return null;
  }
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }

    final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return 'Phone number can only contain numbers';
    }
    if (value.trim().length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    return null;
  }
}