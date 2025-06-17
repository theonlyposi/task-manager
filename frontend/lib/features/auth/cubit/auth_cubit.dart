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
        // Save user and token locally
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

      final userModel = await authRemoteRepository.login(email: email, password: password);

      if (userModel.token.isNotEmpty) {
        await spService.saveToken(userModel.token);
      }

      await authLocalRepository.saveUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:frontend/core/services/sp_service.dart';
// import 'package:frontend/features/auth/repository/auth_local_repository.dart';
// import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
// import 'package:frontend/models/user_model.dart';
//
// part 'auth_state.dart';
//
// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());
//
//   final authRemoteRepository = AuthRemoteRepository();
//   final authLocalRepository = AuthLocalRepository();
//   final spService = SpService();
//
//   Future<void> getUserData() async {
//     try {
//       emit(AuthLoading());
//
//       final token = await spService.getToken();
//       if (token == null || token.isEmpty) {
//         emit(AuthInitial());
//         return;
//       }
//
//       // Pass the token to your repository method
//       final userModel = await authRemoteRepository.getUserData(token: token);
//
//       if (userModel != null) {
//         await authLocalRepository.setToken(userModel);
//         emit(AuthLoggedIn(userModel));
//       } else {
//         emit(AuthInitial());
//       }
//     } catch (e) {
//       emit(AuthInitial());
//     }
//   }
//
//
//   void signUp({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       emit(AuthLoading());
//       await authRemoteRepository.signUp(
//         name: name,
//         email: email,
//         password: password,
//       );
//
//       emit(AuthSignUp());
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }
//
//   void login({required String email, required String password}) async {
//     try {
//       emit(AuthLoading());
//       final userModel = await authRemoteRepository.login(email: email, password: password);
//
//       if (userModel.token.isNotEmpty) {
//         // await spService.setToken(userModel.token);
//         await spService.saveToken(userModel.token); // instead of setToken
//       }
//
//       // await authLocalRepository.insertUser(userModel);
//       await authLocalRepository.saveUser(userModel); // instead of insertUser
//       emit(AuthLoggedIn(userModel));  // This triggers the state to logged in
//     } catch (e) {
//       emit(AuthError(e.toString())
//       );
//     }
//   }
// }
//
//
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:frontend/core/services/sp_service.dart';
// // import 'package:frontend/features/auth/repository/auth_local_repository.dart';
// // import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
// // import 'package:frontend/models/user_model.dart';
// //
// // part 'auth_state.dart';
// //
// // class AuthCubit extends Cubit<AuthState> {
// //   AuthCubit() : super(AuthInitial());
// //   final authRemoteRepository = AuthRemoteRepository();
// //   final authLocalRepository = AuthLocalRepository();
// //   final spService = SpService();
// //
// //   void getUserData() async {
// //     try {
// //       emit(AuthLoading());
// //       final userModel = await authRemoteRepository.getUserData();
// //       if (userModel != null) {
// //         await authLocalRepository.insertUser(userModel);
// //         emit(AuthLoggedIn(userModel));
// //       } else {
// //         emit(AuthInitial());
// //       }
// //     } catch (e) {
// //       print(e);
// //       emit(AuthInitial());
// //     }
// //   }
// //
// //   void signUp({
// //     required String name,
// //     required String email,
// //     required String password,
// //   }) async {
// //     try {
// //       emit(AuthLoading());
// //       await authRemoteRepository.signUp(
// //         name: name,
// //         email: email,
// //         password: password,
// //       );
// //
// //       emit(AuthSignUp());
// //     } catch (e) {
// //       emit(AuthError(e.toString()));
// //     }
// //   }
// //
// //   void login({
// //     required String email,
// //     required String password,
// //   }) async {
// //     try {
// //       emit(AuthLoading());
// //       final userModel = await authRemoteRepository.login(
// //         email: email,
// //         password: password,
// //       );
// //
// //       if (userModel.token.isNotEmpty) {
// //         await spService.setToken(userModel.token);
// //       }
// //
// //       await authLocalRepository.insertUser(userModel);
// //
// //       emit(AuthLoggedIn(userModel));
// //     } catch (e) {
// //       emit(AuthError(e.toString()));
// //     }
// //   }
// // }
