import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_pos/core/theme/app_theme.dart';
import 'package:pharma_pos/features/inventory/presentation/logic/inventory_cubit.dart';
import 'package:pharma_pos/features/pos/presentation/logic/cart_cubit.dart';
import 'package:pharma_pos/features/pos/presentation/pages/pos_page.dart';
import 'package:pharma_pos/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const PharmaPOSApp());
}

class PharmaPOSApp extends StatelessWidget {
  const PharmaPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InventoryCubit>(
          create: (_) => serviceLocator.get<InventoryCubit>(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => serviceLocator.get<CartCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Pharmacy POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightThemeMode,
        home: const POSPage(),
      ),
    );
  }
}
