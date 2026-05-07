import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/core/utils/validators.dart';

void main() {
  test('validates auth form input', () {
    expect(Validators.email('mona@example.com'), isNull);
    expect(Validators.email('bad-email'), isNotNull);
    expect(Validators.password('secret1'), isNull);
    expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
  });
}
