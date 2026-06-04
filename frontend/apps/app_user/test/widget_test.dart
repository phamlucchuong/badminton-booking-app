import 'package:app_user/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_user/main.dart';

void main() {
  testWidgets('app boots with FFAppState provider',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState(),
        child: MyApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
