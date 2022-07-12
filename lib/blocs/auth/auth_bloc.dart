import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safeprint/safeprint.dart';

import '../../models/models.dart';
import '../../repositories/repositories.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc(
    this._authRepository,
  ) : super(Unauthenticated()) {
    on<AuthEvent>((event, emit) async {
      if (event is AppStarted) {
        await _appStartedTrigger(emit);
      } else if (event is Login) {
        await _loginTrigger(emit);
      } else if (event is Logout) {
        await _logoutTrigger(emit);
      }
    });
  }

  Future<void> _appStartedTrigger(
    Emitter<AuthState> emit,
  ) async {
    try {
      User? currentUser = await _authRepository.getCurrentUser();
      currentUser ??= await _authRepository.loginAnonymously();

      final isAnonymous = await _authRepository.isAnonymous();
      if (isAnonymous) {
        emit(Anonymous(currentUser));
      } else {
        emit(Authenticated(currentUser));
      }
    } catch (err) {
      SafePrint.safeDebug(err);
      emit(Unauthenticated());
    }
  }

  Future<void> _loginTrigger(
    Emitter<AuthState> emit,
  ) async {
    try {
      User? currentUser = await _authRepository.getCurrentUser();
      emit(Authenticated(currentUser!));
    } catch (err) {
      SafePrint.safeDebug(err);
      emit(Unauthenticated());
    }
  }

  Future<void> _logoutTrigger(
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      _appStartedTrigger(emit);
    } catch (err) {
      SafePrint.safeDebug(err);
      emit(Unauthenticated());
    }
  }
}
