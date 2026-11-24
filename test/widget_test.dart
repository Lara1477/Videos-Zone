import 'package:flutter_test/flutter_test.dart';
import 'package:videos_app/services/auth_service.dart';

void main() {
  group('Validación de correo', () {
    test('acepta correos válidos', () {
      expect(AuthService.isValidEmail('ana@correo.com'), isTrue);
      expect(AuthService.isValidEmail('  ana.perez+app@mail.co  '), isTrue);
    });

    test('rechaza correos inválidos', () {
      expect(AuthService.isValidEmail(''), isFalse);
      expect(AuthService.isValidEmail('ana'), isFalse);
      expect(AuthService.isValidEmail('ana@'), isFalse);
      expect(AuthService.isValidEmail('ana@correo'), isFalse);
      expect(AuthService.isValidEmail('ana@@correo.com'), isFalse);
    });
  });
}
