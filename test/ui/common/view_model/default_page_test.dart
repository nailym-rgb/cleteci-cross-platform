import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/ui/common/view_model/default_page.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';
import 'package:cleteci_cross_platform/ui/ocr/widgets/ocr.dart';
import 'package:cleteci_cross_platform/ui/settings/widgets/theme_settings_screen.dart';

void main() {
  group('DefaultPageViewModel', () {
    test('appDestinations has correct length', () {
      expect(appDestinations.length, 4);
    });

    test('appDestinations has correct labels', () {
      expect(appDestinations[0].label, 'Dashboard');
      expect(appDestinations[1].label, 'Textract');
      expect(appDestinations[2].label, 'Speech to Text');
      expect(appDestinations[3].label, 'Settings');
    });

    test('appDestinations has correct indices', () {
      expect(appDestinations[0].index, 0);
      expect(appDestinations[1].index, 1);
      expect(appDestinations[2].index, 2);
      expect(appDestinations[3].index, 3);
    });

    test('appDestinations has correct disabled states', () {
      // All destinations should be enabled (false = not disabled)
      for (final destination in appDestinations) {
        expect(destination.disabled, false);
      }
    });

    test('appDestinations has correct icon types', () {
      expect(appDestinations[0].icon, isA<Icon>());
      expect(appDestinations[1].icon, isA<Icon>());
      expect(appDestinations[2].icon, isA<Icon>());
      expect(appDestinations[3].icon, isA<Icon>());
    });

    test('appDestinations has correct selectedIcon types', () {
      expect(appDestinations[0].selectedIcon, isA<Icon>());
      expect(appDestinations[1].selectedIcon, isA<Icon>());
      expect(appDestinations[2].selectedIcon, isA<Icon>());
      expect(appDestinations[3].selectedIcon, isA<Icon>());
    });

    test('pages list has correct length', () {
      expect(pages.length, 4);
    });

    test('pages contains correct widget types', () {
      expect(pages[0], isA<PageComponent>());
      expect(pages[1], isA<OCRScreen>());
      expect(pages[2], isA<PageComponent>());
      expect(pages[3], isA<SettingsPage>());
    });

    test('pages have correct titles', () {
      final page0 = pages[0] as PageComponent;
      final page2 = pages[2] as PageComponent;

      expect(page0.title, 'Dashboard');
      expect(page2.title, 'Speech To Text');
      // Settings page doesn't have title property like PageComponent
    });

    test('pages have correct icons', () {
      final page0 = pages[0] as PageComponent;
      final page2 = pages[2] as PageComponent;

      expect(page0.icon, Icons.widgets);
      expect(page2.icon, Icons.mic);
      // Settings page doesn't have icon property like PageComponent
    });

    test('pages have correct colors', () {
      final page0 = pages[0] as PageComponent;
      final page2 = pages[2] as PageComponent;

      expect(page0.color, Color(0xFF2196F3)); // Blue
      expect(page2.color, Color(0xFFFF9800)); // Orange
      // Settings page doesn't have color property like PageComponent
    });
  });
}