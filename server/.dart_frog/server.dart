// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/api/v1/sales/index.dart' as api_v1_sales_index;
import '../routes/api/v1/inventory/index.dart' as api_v1_inventory_index;


void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/api/v1/sales', (context) => buildApiV1SalesHandler()(context))
    ..mount('/api/v1/inventory', (context) => buildApiV1InventoryHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApiV1SalesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_v1_sales_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1InventoryHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => api_v1_inventory_index.onRequest(context,));
  return pipeline.addHandler(router);
}

