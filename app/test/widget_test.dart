import 'package:flutter_test/flutter_test.dart';

import 'package:gotabgaa/main.dart';

void main() {
  testWidgets('App boots and renders root shell', (WidgetTester tester) async {
    await tester.pumpWidget(const GotabgaaApp());
    // Bottom navigation should be present.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Live TV'), findsWidgets);
  });
}
