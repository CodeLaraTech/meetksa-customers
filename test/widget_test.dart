import 'package:flutter_test/flutter_test.dart';

import 'package:meetksa_customer/app/app.dart';
import 'package:meetksa_customer/app/app_config.dart';
import 'package:meetksa_customer/config/environment.dart';

void main() {
  testWidgets('MeetKSACustomerApp smoke test', (WidgetTester tester) async {
    AppConfig.initialize(config: EnvironmentConfig.production);
    await tester.pumpWidget(const MeetKSACustomerApp());

    expect(find.byType(MeetKSACustomerApp), findsOneWidget);
  });
}

