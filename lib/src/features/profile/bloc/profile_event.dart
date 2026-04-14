part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  ProfileLoadRequested({required this.userId});
}

class ProfileUpdateRequested extends ProfileEvent {
  final String userId;
  final String name;
  final String username;

  ProfileUpdateRequested({
    required this.userId,
    required this.name,
    required this.username,
  });
}

class ProfilePhotoUploadRequested extends ProfileEvent {
  final String userId;
  final String? filePath;
  final List<int>? fileBytes;
  final String fileName;

  ProfilePhotoUploadRequested({
    required this.userId,
    this.filePath,
    this.fileBytes,
    required this.fileName,
  });
}

class ProfileDeleteRequested extends ProfileEvent {
  final String userId;
  ProfileDeleteRequested({required this.userId});
}

class ProfileHistoryLoadRequested extends ProfileEvent {
  final String userId;
  final bool reset;

  ProfileHistoryLoadRequested({
    required this.userId,
    this.reset = false,
  });
}

