import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    getUserData();
  }

  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  Future<void> getUserData() async {
    try {
      emit(AuthLoading());

      final token = await spService.getToken();
      if (token == null || token.isEmpty) {
        emit(AuthInitial());
        return;
      }

      final userModel = await authRemoteRepository.getUserData(token: token);
      if (userModel != null) {
        await authLocalRepository.saveUser(userModel);
        await spService.saveToken(userModel.token);
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.saveToken(userModel.token);
      }

      await authLocalRepository.saveUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String token,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      emit(AuthLoading());

      final updatedUser = await authRemoteRepository.updateProfile(
        token: token,
        name: name,
        email: email,
        password: password,
      );

      if (updatedUser != null) {
        await authLocalRepository.saveUser(updatedUser);
        emit(AuthLoggedIn(updatedUser));
      } else {
        emit(AuthError("Profile update failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
