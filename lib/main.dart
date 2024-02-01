// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:visual_subs/widgets/main_screen/mobile_home_page.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import 'package:visual_subs/states/audio_state.dart';
import 'package:visual_subs/states/colors_state.dart';
import 'package:visual_subs/states/image_state.dart';
import 'package:visual_subs/states/options_state.dart';
import 'package:visual_subs/states/subtitle_state.dart';
import 'package:visual_subs/widgets/main_screen/desktop_home_page.dart';
import 'extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformCheck.isDesktop) {
    await windowManager.ensureInitialized();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OptionsState()),
        ChangeNotifierProvider(create: (context) => ImageState()),
        ChangeNotifierProvider(create: (context) => SubtitleState()),
        ChangeNotifierProvider(create: (context) => AudioState()),
        ChangeNotifierProvider(create: (context) => ColorsState()),
      ],
      child: MaterialApp(
        title: 'Visual Subs',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: PlatformCheck.isMobile
            ? const MobileHomePage()
            : const DesktopHomePage(),
      ),
    );
  }
}
