/// Class that holds all validator.
class Validator {
  /// Validates whether a given value is a valid user name.
  static String? username(String? val) {
    if (val == null) {
      return 'Please enter more then 1 letters';
    }
    if (val.isEmpty) {
      return 'Please enter more then 1 letters';
    }
    final regex = RegExp(r'^\w*$');
    if (!regex.hasMatch(val)) {
      return 'Alphabets, numbers and underscore is allowed';
    }
    return null;
  }
}
