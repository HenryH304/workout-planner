import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  group('US-005: Exercise database JSON', () {
    test('exercises.json exists and is valid JSON', () async {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final exercises = jsonDecode(jsonString) as List;

      expect(exercises.length, greaterThanOrEqualTo(50));
    });

    test('exercises.json contains exercises with all required fields', () async {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final exercisesList = jsonDecode(jsonString) as List;

      for (final exercise in exercisesList) {
        expect(exercise['id'], isNotNull);
        expect(exercise['name'], isNotNull);
        expect(exercise['primaryMuscles'], isNotNull);
        expect(exercise['secondaryMuscles'], isNotNull);
        expect(exercise['equipment'], isNotNull);
        expect(exercise['category'], isNotNull);
      }
    });

    test('exercises.json covers all muscle groups', () async {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final exercisesList = jsonDecode(jsonString) as List;

      final allMuscles = <String>{};
      for (final exercise in exercisesList) {
        final primaryMuscles = exercise['primaryMuscles'] as List?;
        final secondaryMuscles = exercise['secondaryMuscles'] as List?;

        if (primaryMuscles != null) {
          allMuscles.addAll(primaryMuscles.cast<String>());
        }
        if (secondaryMuscles != null) {
          allMuscles.addAll(secondaryMuscles.cast<String>());
        }
      }

      expect(allMuscles, containsAll([
        'chest', 'back', 'shoulders', 'biceps', 'triceps', 'core',
        'quads', 'hamstrings', 'glutes', 'calves'
      ]));
    });

    test('exercises.json uses valid equipment types', () async {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final exercisesList = jsonDecode(jsonString) as List;

      final validEquipment = {
        'dumbbells', 'barbells', 'cables', 'machines', 'bodyweight', 'kettlebells'
      };

      for (final exercise in exercisesList) {
        final equipment = exercise['equipment'] as String;
        expect(validEquipment, contains(equipment));
      }
    });

    test('exercises.json uses valid categories', () async {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final exercisesList = jsonDecode(jsonString) as List;

      final validCategories = {'push', 'pull', 'legs', 'core', 'cardio'};

      for (final exercise in exercisesList) {
        final category = exercise['category'] as String;
        expect(validCategories, contains(category));
      }
    });
  });
}
