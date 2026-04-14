import 'package:chess/src/core/app.dart';
import 'package:chess/src/features/landing/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepository = AuthRepository();
  await authRepository.initialize();
  await GetStorage.init();
  runApp(App(authRepository: authRepository));
}
