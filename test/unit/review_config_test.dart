import 'package:flutter_test/flutter_test.dart';
import 'package:umra_flutter/constants/review_config.dart';

void main() {
  group('ReviewConfig', () {
    // Guards against accidentally shipping a build with the in-app-review
    // prompt in test mode (every-launch prompting), which would be flagged by
    // both stores and annoy users.
    test('ships in production mode', () {
      expect(ReviewConfig.isTestMode, isFalse);
    });

    test('production thresholds follow store best practices', () {
      expect(ReviewConfig.minUsageTimeSeconds, 180);
      expect(ReviewConfig.minAppLaunches, 3);
      expect(ReviewConfig.minDaysSinceFirstLaunch, 1);
      expect(ReviewConfig.daysBetweenPrompts, 90);
      expect(ReviewConfig.maxTotalPrompts, 3);
    });
  });
}
