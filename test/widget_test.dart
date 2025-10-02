import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the Today screen
    expect(find.text('Today\'s Tasks'), findsOneWidget);
  });
}
