import 'package:flutter_test/flutter_test.dart';
import 'package:webview_debug_flutter/main.dart';

void main() {
  testWidgets('App loads config screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WebViewDebugApp());
    expect(find.text('WebView Debug Config'), findsOneWidget);
  });
}
