import 'package:day35/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Online Thekedaar opens service selection', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OnlineThekedaarApp());

    expect(find.text('Online Thekedaar'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump();

    expect(find.text('🔧 Plumber'), findsOneWidget);
    expect(find.text('💡 Electrician'), findsOneWidget);
    expect(find.text('Book trusted local service workers'), findsOneWidget);
  });
}
