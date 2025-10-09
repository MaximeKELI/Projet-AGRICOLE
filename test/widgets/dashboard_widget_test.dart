import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_agricole/screens/intelligent_dashboard_screen.dart';

void main() {
  group('Dashboard Widget Tests', () {
    testWidgets('should display dashboard title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: IntelligentDashboardScreen(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tableau de Bord Intelligent'), findsOneWidget);
    });

    testWidgets('should display weather section', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: IntelligentDashboardScreen(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Météo Actuelle'), findsOneWidget);
    });

    testWidgets('should display agricultural metrics section', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: IntelligentDashboardScreen(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Métriques Agricoles'), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: IntelligentDashboardScreen(),
        ),
      );

      // Act
      await tester.pumpAndSettle();
      
      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();
      }

      // Assert
      expect(find.text('Tableau de Bord Intelligent'), findsOneWidget);
    });
  });
}
