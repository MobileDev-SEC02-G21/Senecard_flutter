class AppRegex {
  const AppRegex._();

  static final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]{1,253}\.[a-zA-Z]{2,}$");
  static final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$#!%*?&_])[A-Za-z\d@#$!%*?&_].{7,}$');
  static final RegExp nameRegex = RegExp(
      r"^[a-zA-Z]+( [a-zA-Z]+)?$");
  static final RegExp phoneRegex = RegExp(
      r"^[0-9]{10}$");
}
