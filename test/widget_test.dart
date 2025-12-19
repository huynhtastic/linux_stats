import 'package:flutter_test/flutter_test.dart';
import 'package:gpu_usage_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that our title is present.
    expect(find.text('GPU USAGE'), findsOneWidget);
  });
}
