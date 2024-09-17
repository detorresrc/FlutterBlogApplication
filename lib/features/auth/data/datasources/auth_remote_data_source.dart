import 'package:blog_app_clean_architecture/core/error/exceptions.dart';
import 'package:blog_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPasword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmailPasword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailPasword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw ServerException(message: "User is null");
      }

      return UserModel.fromJson(response.user!.toJson()).copyWith(email: email);
    } on AuthException catch (e) {
      throw ServerException(message: e.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPasword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await supabaseClient.auth
          .signUp(email: email, password: password, data: {
        'name': name,
      });

      if (response.user == null) {
        throw ServerException(message: "User is null");
      }

      return UserModel.fromJson(response.user!.toJson()).copyWith(email: email);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession == null) {
        return null;
      }

      final userData = await supabaseClient
          .from('profiles')
          .select()
          .eq("id", currentUserSession!.user.id);

      return UserModel.fromJson(
        userData.first,
      ).copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
