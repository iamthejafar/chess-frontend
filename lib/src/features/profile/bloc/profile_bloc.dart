import 'package:chess/src/features/landing/models/user_model.dart';
import 'package:chess/src/features/landing/repositories/user_repository.dart';
import 'package:chess/src/features/profile/models/game_history_models.dart';
import 'package:chess/src/services/storage_service.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final StorageService _storageService;
  final Logger _logger = Logger();

  ProfileBloc({
    required UserRepository userRepository,
    required StorageService storageService,
  })  : _userRepository = userRepository,
        _storageService = storageService,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfilePhotoUploadRequested>(_onPhotoUploadRequested);
    on<ProfileDeleteRequested>(_onDeleteRequested);
    on<ProfileHistoryLoadRequested>(_onHistoryLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _userRepository.getUser(event.userId);
      if (user == null) {
        emit(ProfileError(message: 'User not found'));
      } else {
        emit(ProfileLoaded(user: user));
        add(ProfileHistoryLoadRequested(userId: event.userId, reset: true));
      }
    } catch (e) {
      _logger.e('Error loading profile: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isBusy: true, busyMessage: 'Updating profile…'));

    try {
      final updated = await _userRepository.updateUser(
        userId: event.userId,
        name: event.name,
        username: event.username,
      );

      if (updated == null) throw Exception('No data returned from server');

      await _storageService.saveUser(updated);
      emit(ProfileUpdateSuccess(user: updated, message: 'Profile updated successfully'));
      emit(currentState.copyWith(
        user: updated,
        isBusy: false,
        busyMessage: null,
      ));
    } catch (e) {
      _logger.e('Error updating profile: $e');
      emit(ProfileError(message: 'Failed to update profile: $e'));
      emit(currentState.copyWith(isBusy: false, busyMessage: null));
    }
  }

  Future<void> _onPhotoUploadRequested(
    ProfilePhotoUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isBusy: true, busyMessage: 'Uploading photo…'));

    try {
      await _userRepository.uploadProfilePhoto(
        userId: event.userId,
        filePath: event.filePath,
        fileBytes: event.fileBytes,
        fileName: event.fileName,
      );

      final refreshed = await _userRepository.getUser(event.userId);
      if (refreshed != null) {
        await _storageService.saveUser(refreshed);
        emit(ProfileUpdateSuccess(user: refreshed, message: 'Profile photo updated'));
        emit(currentState.copyWith(
          user: refreshed,
          isBusy: false,
          busyMessage: null,
        ));
      } else {
        emit(currentState.copyWith(isBusy: false, busyMessage: null));
      }
    } catch (e) {
      _logger.e('Error uploading photo: $e');
      emit(ProfileError(message: 'Failed to upload photo: $e'));
      emit(currentState.copyWith(isBusy: false, busyMessage: null));
    }
  }

  Future<void> _onDeleteRequested(
    ProfileDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isBusy: true, busyMessage: 'Deleting profile…'));

    try {
      await _userRepository.deleteUser(event.userId);
      await _storageService.clearUser();
      emit(ProfileDeleted());
    } catch (e) {
      _logger.e('Error deleting profile: $e');
      emit(ProfileError(message: 'Failed to delete profile: $e'));
      emit(currentState.copyWith(isBusy: false, busyMessage: null));
    }
  }

  Future<void> _onHistoryLoadRequested(
    ProfileHistoryLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    if (currentState.isHistoryLoading) return;
    if (!event.reset && !currentState.hasMoreHistory) return;

    final targetPage = event.reset ? 0 : currentState.nextHistoryPage;

    emit(currentState.copyWith(
      isHistoryLoading: true,
      historyError: null,
    ));

    try {
      final page = await _userRepository.getGameHistoryPage(
        userId: event.userId,
        page: targetPage,
        size: currentState.historyPageSize,
      );

      final mergedGames = event.reset
          ? page.games
          : [...currentState.games, ...page.games];

      emit(currentState.copyWith(
        games: mergedGames,
        isHistoryLoading: false,
        hasMoreHistory: page.hasNext,
        nextHistoryPage: targetPage + 1,
        historyError: null,
      ));
    } catch (e) {
      _logger.e('Error loading game history: $e');
      emit(currentState.copyWith(
        isHistoryLoading: false,
        historyError: 'Failed to load games: $e',
      ));
    }
  }
}


