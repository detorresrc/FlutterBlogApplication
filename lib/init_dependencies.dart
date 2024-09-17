import 'package:blog_app_clean_architecture/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app_clean_architecture/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app_clean_architecture/core/network/connection_checker.dart';
import 'package:blog_app_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_app_clean_architecture/features/auth/domain/usecases/current_user.dart';
import 'package:blog_app_clean_architecture/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app_clean_architecture/features/auth/domain/usecases/user_signup.dart';
import 'package:blog_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app_clean_architecture/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_app_clean_architecture/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/usecases/upload_blog.dart';
import 'package:blog_app_clean_architecture/features/blog/presentation/bloc/blog_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();

  // Supabase
  final supabase = await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_API_KEY'),
    debug: true,
  );
  serviceLocator.registerLazySingleton(
    () => supabase.client,
  );

  // Hive
  Hive.defaultDirectory = (await getApplicationCacheDirectory()).path;
  serviceLocator.registerLazySingleton<Box>(
    () => Hive.box(name: 'blogs'),
  );

  // Core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      connectionChecker: InternetConnection(),
    ),
  );
}

void _initBlog() {
  serviceLocator.registerFactory<BlogRemoteDataSource>(
    () => BlogRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );
  serviceLocator.registerFactory<BlogLocalDataSource>(
    () => BlogLocalDataSourceImpl(
      box: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<BlogRepository>(
    () => BlogRepositoryImpl(
      blogLocalDataSource: serviceLocator(),
      blogRemoteDataSource: serviceLocator(),
      connectionChecker: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UploadBlog(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => GetAllBlogs(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => BlogBloc(
      uploadBlog: serviceLocator(),
      getAllBlogs: serviceLocator(),
    ),
  );
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignup(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserLogin(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => CurrentUser(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}
