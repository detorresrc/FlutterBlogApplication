part of "init_dependencies.dart";

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
