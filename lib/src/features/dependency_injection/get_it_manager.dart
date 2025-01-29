import 'dart:io';
import '../../core/utils/utility.dart';

class GetItManager {
  static Future<void> manageGetIt(String featureName , [String? stateManagement , String? architecture]) async {
    
     if (architecture?.toLowerCase() != 'clean') {
    return;
  }
    String? response = 'yes';

    if (!doesInjectionFileExist()) {
      stdout.write(
          'Do you want to use GetIt for dependency injection? (yes/no): ');
      response = stdin.readLineSync()?.trim().toLowerCase();
    }

    if (response != 'yes') {
      print('Skipping GetIt setup.');
      return;
    } else {
      if (await Utility.addDependency('get_it')) {
        final injectionFilePath = 'lib/injection.dart';
        final mainFilePath = 'lib/main.dart';

        if (File(injectionFilePath).existsSync()) {
          print('File injection.dart already exists.');
        } else {
          const content = '''
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register your dependencies here.
}
''';
          await File(injectionFilePath).writeAsString(content);
          print('File injection.dart created successfully.');
        }

        if (!File(mainFilePath).existsSync()) {
          print('Error: lib/main.dart not found.');
          return;
        }

        final mainFile = File(mainFilePath);
        String mainContent = await mainFile.readAsString();

        final mainPattern = RegExp(r'Future<void>\s+main\(\)\s*async');
        if (!mainPattern.hasMatch(mainContent)) {
          mainContent = mainContent.replaceFirst(
            RegExp(r'void\s+main\(\)'),
            'Future<void> main() async',
          );
        }

        if (!mainContent
            .contains('WidgetsFlutterBinding.ensureInitialized()')) {
          mainContent = mainContent.replaceFirst(
            '{',
            '{\n  WidgetsFlutterBinding.ensureInitialized();',
          );
        }

        if (!mainContent.contains("import 'injection.dart' as injection")) {
          mainContent = "import 'injection.dart' as injection;\n$mainContent";
        }

        if (!mainContent.contains('await injection.init();')) {
          mainContent = mainContent.replaceFirst(
            'runApp(',
            'await injection.init();\n  runApp(',
          );
        }

        await mainFile.writeAsString(mainContent);
        createAndRegisterMethod(featureName );
        print('main.dart updated successfully.');
      }
    }
  }

  static Future<void> createAndRegisterMethod(String featureName,) async {
    final injectionFilePath = 'lib/injection.dart';

    if (!File(injectionFilePath).existsSync()) {
      return;
    }

    final injectionFile = File(injectionFilePath);
    String injectionContent = await injectionFile.readAsString();
    String className = Utility.convertCase(featureName, toCamelCase: true);
    String imports = '';
      imports = '''
import 'features/$featureName/data/data_sources/${featureName}_data_source.dart';
import 'features/$featureName/data/repositories/${featureName}_repository_implement.dart';
import 'features/$featureName/domain/repositories/${featureName}_repository.dart';
import 'features/$featureName/domain/usecases/${featureName}_usecase.dart';
import 'features/$featureName/presentation/manager/bloc/$featureName/${featureName}_bloc.dart';
''';
   

    if (!injectionContent.contains(imports)) {
      injectionContent = '$imports\n$injectionContent';
    }

    final methodContent = '''

Future<void> _setUp$className() async {
   // BLoC
  sl.registerFactory(() => ${className}Bloc());

  // Repositories
  sl.registerLazySingleton<${className}Repository>(() => ${className}RepositoryImplement(dataSource:sl()));

  // Use Cases
  sl.registerLazySingleton(() => ${className}UseCase(repository: sl()));

  // Data Sources
  sl.registerLazySingleton<${className}DataSource>(() => ${className}DataSourceImplement());
}
''';

    if (!injectionContent.contains('Future<void> _setUp$className()')) {
      injectionContent += methodContent;
      print('Method setUp$className added successfully to injection.dart.');
    } else {
      print('Method setUp$className already exists in injection.dart.');
    }

    final initCall = '  await _setUp$className();\n';

    if (!injectionContent.contains(initCall)) {
      injectionContent = injectionContent.replaceFirst(
        'Future<void> init() async {',
        'Future<void> init() async {\n$initCall',
      );
      print('Feature $featureName registered successfully in init method.');
    } else {
      print('Feature $featureName is already registered in init method.');
    }

    await injectionFile.writeAsString(injectionContent);
  }

  static Future<void> registerBloc(
      String featureName, String name) async {
          final className = Utility.convertCase(name, toCamelCase: true);
          final fileName = Utility.convertCase(className, toCamelCase: false);
    await _registerComponent(
        featureName,
        className,
        'Bloc',
        (className) => 'sl.registerFactory(() => ${className}Bloc());',
        (featureName) =>
            "import 'features/$featureName/presentation/manager/bloc/$fileName/${fileName}_bloc.dart';");
  }

  static Future<void> registerUseCase(
    String featureName, String name) async {
  final baseName = name.contains(":") ? name.split(":")[0] : name;
  final className = Utility.convertCase(baseName, toCamelCase: true);

  await _registerComponent(
    featureName,
    className,
    'UseCase',
    (className) => 
        'sl.registerLazySingleton(() => ${className}UseCase(repository: sl()));',
    (featureName) =>
        "import 'features/$featureName/domain/usecases/${baseName}_usecase.dart';",
  );
}


  static Future<void> registerRepository(
      String featureName, String name) async {

    final className = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(className, toCamelCase: false);
    await _registerComponent(
        featureName,
        className,
        'Repository',
        (className) =>
            'sl.registerLazySingleton<${className}Repository>(() => ${className}RepositoryImplement(dataSource:sl()));',
        (featureName) =>
            "import 'features/$featureName/data/repositories/${fileName}_repository_implement.dart';\nimport 'features/$featureName/domain/repositories/${fileName}_repository.dart';");
  }

  static Future<void> registerDataSource(
      String featureName, String name) async {
            final className = Utility.convertCase(name, toCamelCase: true);
    await _registerComponent(
        featureName,
        className,
        'DataSource',
        (className) =>
            'sl.registerLazySingleton<${className}DataSource>(() => ${className}DataSourceImplement());',
        (featureName) =>
            "import 'features/$featureName/data/data_sources/${featureName}_data_source.dart';");
  }

  static Future<void> _registerComponent(
    String featureName,
    String className,
    String componentType,
    String Function(String className) getRegistrationCode,
    String Function(String featureName) getImportStatement,
  ) async {
    final injectionFilePath = 'lib/injection.dart';

    if (!File(injectionFilePath).existsSync()) {
      return;
    }

    final injectionFile = File(injectionFilePath);
    String injectionContent = await injectionFile.readAsString();

    final methodName =
        '_setUp${Utility.convertCase(featureName, toCamelCase: true)}';
    final registrationCode = getRegistrationCode(className);
    final importStatement = getImportStatement(featureName);

    print('Generated methodName: $methodName');

    if (!injectionContent.contains(importStatement)) {
      final importPattern = RegExp(r'(^|\n)import .+;');
      final match = importPattern.allMatches(injectionContent).lastOrNull;
      if (match != null) {
        injectionContent = injectionContent.replaceRange(
          match.end,
          match.end,
          '\n$importStatement',
        );
      } else {
        injectionContent = '$importStatement\n\n$injectionContent';
      }
      print('Import added: $importStatement');
    } else {
      print('Import already exists: $importStatement');
    }

    final methodPattern = RegExp('Future<void> $methodName\\(\\) async \\{');

    if (!methodPattern.hasMatch(injectionContent)) {
      print('Method $methodName not found. Adding the method.');
      injectionContent +=
          '\nFuture<void> $methodName() async {\n  // TODO: Add your registration logic here\n}\n';
    }

    if (!injectionContent.contains(registrationCode)) {
      injectionContent = injectionContent.replaceFirst(
        methodPattern,
        'Future<void> $methodName() async {\n  $registrationCode\n',
      );
      print('$componentType registered successfully in $methodName.');
    } else {
      print('$componentType is already registered in $methodName.');
    }

    await injectionFile.writeAsString(injectionContent);
  }

  static bool doesInjectionFileExist() {
    final injectionFilePath = 'lib/injection.dart';
    return File(injectionFilePath).existsSync();
  }

  static Future<void> registerStateManagement(
      String featureName, String name, String type) async {
    switch (type.toLowerCase()) {
      case 'bloc':
        await registerBloc(featureName, name);
      case 'getx':
        await registerGetX(featureName, name);
      case 'provider':
        await registerProvider(featureName, name);
      default:
        print('Invalid state management type: $type');
    }
  }

  static Future<void> registerGetX(
      String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(className, toCamelCase: false);
    await _registerComponent(
        featureName,
        className,
        'Controller',
        (className) => 'sl.registerFactory(() => ${className}Controller());',
        (featureName) =>
            "import 'features/$featureName/presentation/manager/controller/${fileName}_controller.dart';");
  }

  static Future<void> registerProvider(
      String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(className, toCamelCase: false);
    await _registerComponent(
        featureName,
        className,
        'Provider',
        (className) => 'sl.registerFactory(() => ${className}Provider());',
        (featureName) =>
            "import 'features/$featureName/presentation/manager/provider/${fileName}_provider.dart';");
  }
}
