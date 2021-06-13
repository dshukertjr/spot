import 'package:flutter_test/flutter_test.dart';
import 'package:spot/app/validators.dart';

void main() {
  group('Valid username', () {
    test('Alphabets and nnumbers', () {
      final username = 'someAnother23';
      final validationResult = Validator.username(username);
      expect(validationResult, isNull);
    });
    test('Alphabets and nuderbars and unnderbar', () {
      final username = 'Some_another23';
      final validationResult = Validator.username(username);
      expect(validationResult, isNull);
    });
  });
  group('Invalid username', () {
    test('null username', () {
      final username = null;
      final validationResult = Validator.username(username);
      expect(validationResult, 'Please enter more then 1 letters');
    });
    test('Empty username', () {
      final username = '';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Please enter more then 1 letters');
    });
    test('Contains emoji', () {
      final username = 'some🌏';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
    test('Contains space', () {
      final username = 'some another';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
    test('Contains @', () {
      final username = 'som@eanother';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
    test('Contains !', () {
      final username = 'som!eanother';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
    test('Contains ?', () {
      final username = 'som?eanother';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
    test('Contains Japannese', () {
      final username = 'some貴洋';
      final validationResult = Validator.username(username);
      expect(validationResult, 'Alphabets, numbers and underscore is allowed');
    });
  });
}
