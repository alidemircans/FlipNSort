import 'dart:io';

import 'package:FlipNSort/store_config.dart';
import 'package:flutter/material.dart';
import 'package:FlipNSort/main_menu.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(
      store: StoreEnum.appleStore,
      apiKey: "appl_HhfWsxjqNwcYKlsesRPsNWXTvnD",
    );
  } else if (Platform.isAndroid) {
    StoreConfig(
      store: StoreEnum.googlePlay,
      apiKey: "",
    );
  }
  await _configureSDK();

  runApp(const MyApp());
}

Future<void> _configureSDK() async {
  PurchasesConfiguration configuration;

  configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
    ..appUserID = null
    ..observerMode = false;

  await Purchases.configure(configuration);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flip N' Short",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainMenu(),
    );
  }
}
