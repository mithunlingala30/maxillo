import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// App-wide observable state: current Firebase user + their full
/// Firestore profile. Screens listen to this via [Provider] so the
/// Profile screen, Home greeting, and prediction flow always have
/// up-to-date user details.
class AppState extends ChangeNotifier {
  final AuthService authService;
  final UserService userService;

  AppState({AuthService? authService, UserService? userService})
      : authService = authService ?? AuthService(),
        userService = userService ?? UserService() {
    _authSub = this.authService.authStateChanges.listen(_onAuthChanged);
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  AuthStatus status = AuthStatus.unknown;
  AppUser? profile;
  bool hasSeenOnboarding = false;

  Future<void> _onAuthChanged(User? user) async {
    await _profileSub?.cancel();
    if (user == null) {
      status = AuthStatus.signedOut;
      profile = null;
      notifyListeners();
      return;
    }
    status = AuthStatus.signedIn;
    _profileSub = userService.watchUserProfile(user.uid).listen((p) {
      profile = p;
      notifyListeners();
    });
    notifyListeners();
  }

  void markOnboardingSeen() {
    hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;
    profile = await userService.getUserProfile(uid);
    notifyListeners();
  }

  Future<void> signOut() async {
    await authService.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
