import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../peco_note_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A hot restart keeps the native iOS keyboard alive while rebuilding the
  // Dart UI. Hide that stale keyboard before mounting the new widget tree to
  // avoid UIKit's TUIKeyplane constraint warning.
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: PecoNoteApp()));
}
