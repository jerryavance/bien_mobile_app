// lib/services/launch_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaunchService {
  static const _keyOnboardingShown = 'onboarding_shown';

  /// Returns the route the app should start with.
  static Future<String> initialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keyOnboardingShown) ?? false;

    // Change the logic here if you also want a login check, etc.
    return shown ? '/login' : '/splash';
  }

  /// Call this **once** when onboarding finishes.
  static Future<void> markOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingShown, true);
  }
}