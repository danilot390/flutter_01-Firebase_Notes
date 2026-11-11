import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/main.dart';

void main() {
  testWidgets('App displays its home screen',(
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Firebase Notes'), findsOneWidget);
  });
}