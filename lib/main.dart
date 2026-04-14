import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/inventory/presentation/logic/inventory_cubit.dart';
import 'features/pos/presentation/logic/cart_cubit.dart';
import 'features/pos/presentation/pages/pos_page.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      fullScreen: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const PharmaPOSApp());
}

class PharmaPOSApp extends StatelessWidget {
  const PharmaPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => serviceLocator.get<ThemeCubit>(),
        ),
        BlocProvider<InventoryCubit>(
          create: (_) => serviceLocator.get<InventoryCubit>(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => serviceLocator.get<CartCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'PharmaPOS',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            home: const POSPage(),
          );
        },
      ),
    );
  }
}
