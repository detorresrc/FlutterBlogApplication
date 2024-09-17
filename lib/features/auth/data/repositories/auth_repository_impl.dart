import 'package:blog_app_clean_architecture/core/error/exceptions.dart';
import 'package:blog_app_clean_architecture/core/error/failures.dart';
import 'package:blog_app_clean_architecture/core/network/connection_checker.dart';
import 'package:blog_app_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:blog_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app_clean_architecture/core/common/entities/user.dart';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl(this.authRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _getUser(() async {
      return await authRemoteDataSource.loginWithEmailPasword(
        email: email,
        password: password,
      );
    });
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _getUser(() async {
      return await authRemoteDataSource.signUpWithEmailPasword(
        email: email,
        password: password,
        name: name,
      );
    });
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = authRemoteDataSource.currentUserSession;
        if (session == null) return Left(Failure('User not logged in'));

        return Right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? "",
            name: "",
          ),
        );
      }

      final user = await authRemoteDataSource.getCurrentUserData();
      if (user == null) {
        return Left(Failure('User not logged in'));
      }

      return Right(user);
    } on ServerException catch (e) {
      return Left(
        Failure(e.message),
      );
    }
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      final isConnected = await connectionChecker.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }

      return Right(await fn());
    } on sb.AuthException catch (e) {
      return Left(Failure(e.message));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
