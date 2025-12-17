import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sakina/features/azkar/data/datasources/azkar_local_data_source.dart';
import 'package:sakina/features/azkar/data/repositories/azkar_repository_impl.dart';
import 'package:sakina/features/azkar/domain/repositories/azkar_repository.dart';
import 'package:sakina/features/azkar/domain/usecases/get_all_azkar.dart';
import 'package:sakina/features/azkar/domain/usecases/get_random_zekr.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/daily_dua/data/datasources/dua_local_data_source.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/prayer_times/data/datasources/prayer_times_remote_data_source.dart';
import 'package:sakina/features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import 'package:sakina/features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/usecases/cache_prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_cached_prayer_times.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/azan_bloc.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_azan_settings.dart';
import 'package:sakina/features/prayer_times/domain/usecases/save_azan_settings.dart';
import 'package:sakina/features/prayer_times/domain/repositories/azan_repository.dart';
import 'package:sakina/features/prayer_times/data/repositories/azan_repository_impl.dart';
import 'package:sakina/features/prayer_times/data/services/azan_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(
    () => PrayerTimesBloc(
      getPrayerTimes: sl(),
      cachePrayerTimes: sl(),
      getCachedPrayerTimes: sl(),
      getAzanSettings: sl(),
    ),
  );

  sl.registerFactory(
    () => AzkarBloc(
      getAllAzkar: sl(),
      getRandomZekr: sl(),
    ),
  );

  sl.registerFactory(
    () => DuaBloc(dataSource: sl()),
  );

  sl.registerFactory(
    () => DailyActivityBloc(),
  );

  sl.registerFactory(
    () => AzanBloc(
      getAzanSettings: sl(),
      saveAzanSettings: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPrayerTimes(sl()));
  sl.registerLazySingleton(() => CachePrayerTimes());
  sl.registerLazySingleton(() => GetCachedPrayerTimes());
  sl.registerLazySingleton(() => GetAllAzkar(sl()));
  sl.registerLazySingleton(() => GetRandomZekr(sl()));
  sl.registerLazySingleton(() => GetAzanSettings(sl()));
  sl.registerLazySingleton(() => SaveAzanSettings(sl()));

  // Repositories
  sl.registerLazySingleton<PrayerTimesRepository>(
    () => PrayerTimesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<AzanRepository>(
    () => AzanRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<DuaLocalDataSource>(
    () => DuaLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AzanService>(
    () => AzanService(),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}
