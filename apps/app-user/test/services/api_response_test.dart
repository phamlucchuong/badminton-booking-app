import 'package:flutter_test/flutter_test.dart';
import 'package:app_user/services/api_response.dart';
import 'package:app_user/services/api_exception.dart';

void main() {
  test('unwrap returns data on code 200', () {
    final data = ApiResponse.unwrap(
      '{"code":200,"message":"ok","data":{"x":1}}',
      statusCode: 200,
      uri: Uri.parse('http://localhost/api'),
    );
    expect(data, {'x': 1});
  });

  test('unwrap throws ApiException on non-200 code', () {
    expect(
      () => ApiResponse.unwrap(
        '{"code":2001,"message":"Tài khoản không tồn tại"}',
        statusCode: 400,
        uri: Uri.parse('http://localhost/api'),
      ),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 2001)
          .having((e) => e.message, 'message', 'Tài khoản không tồn tại')),
    );
  });

  test('unwrap returns null data when absent', () {
    final data = ApiResponse.unwrap(
      '{"code":200,"message":"ok"}',
      statusCode: 200,
      uri: Uri.parse('http://localhost/api'),
    );
    expect(data, isNull);
  });
}
