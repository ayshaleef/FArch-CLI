import 'dart:async';
import 'dart:io';
import '../bin/utils/logger.dart';

class Utility {
  static bool isValidFeatureName(String name) {
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    return nameRegExp.hasMatch(name);
  }

  static Future<void> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  static Future<void> writeFileWithBackup(String path, String content) async {
    final file = File(path);
    if (file.existsSync()) {
      await file.copy('$path.backup');
    }
    await file.writeAsString(content);
  }

  static String convertCase(String input, {required bool toCamelCase}) {
    if (toCamelCase) {
      if (!input.contains('_')) {
        return input[0].toUpperCase() + input.substring(1).toLowerCase();
      }
      return input.split('_').map((word) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join('');
    } else {
      return input
          .replaceAllMapped(
            RegExp(r'[A-Z]'),
            (match) => '_${match.group(0)!.toLowerCase()}',
          )
          .replaceFirst('_', '');
    }
  }

  static String getFilePath(String featureName, String type, String name) {
    return 'lib/features/$featureName/$type/$name.dart';
  }

  static void writeFile(String filePath, String content) {
    final file = File(filePath);
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
  }

  static String readFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }
    return file.readAsStringSync();
  }

  static Future<bool> addDependency(String dependency) async {
    try {
      final projectDirectory = Directory.current.path;

      final pubspec = File('$projectDirectory/pubspec.yaml');
      if (!pubspec.existsSync()) {
        print(
            'Error: pubspec.yaml not found in the current project directory: $projectDirectory');
        return false;
      }

      final pubspecContent = await pubspec.readAsString();

      if (pubspecContent
          .contains(RegExp('^\\s*$dependency:', multiLine: true))) {
        print('Dependency "$dependency" is already present in pubspec.yaml.');
        return true;
      }

      stdout.write('Adding dependency "$dependency" to pubspec.yaml');

      Timer? timer;
      timer = Timer.periodic(Duration(milliseconds: 300), (t) {
        stdout.write('.');
      });

      final process = await Process.run(
        'cmd',
        ['/c', 'flutter', 'pub', 'add', dependency],
        workingDirectory: projectDirectory,
      );

      timer.cancel();
      stdout.writeln();

      if (process.exitCode == 0) {
        print(
            'Dependency "$dependency" added successfully to the project at $projectDirectory.');
        return true;
      } else {
        print('Error adding dependency: ${process.stderr}');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }

  static Future<void> formatFile(String filePath) async {
    try {
      final process = await Process.run(
        'dart',
        ['format', filePath],
      );

      if (process.exitCode == 0) {
        Logger.success('File $filePath formatted successfully.');
      } else {
        Logger.error('Error formatting file: ${process.stderr}');
      }
    } catch (e) {
      Logger.error('An error occurred while formatting the file: $e');
    }
  }
}
