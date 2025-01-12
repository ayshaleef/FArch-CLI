import 'dart:io';
import 'get_it_manager.dart';
import 'architectures/mvc_architecture.dart';
import 'architectures/mvvm_architecture.dart';
import 'architectures/clean_architecture.dart';
import 'utils/logger.dart';

class FArch {
  void printUsage() {
    print('Usage:');
    print('To create feature (with interactive prompts): farch "FeatureName"');
    print('To create feature with specific architecture: farch "FeatureName" --mvc|--mvvm|--clean');
    print('To create use case: farch "FeatureName" -u "UseCaseName"');
    print('To create model: farch "FeatureName" -m "ModelName"');
    print('To create repository: farch "FeatureName" -r "RepositoryName"');
    print('To create data source: farch "FeatureName" -d "DataSourceName"');
    print('To create state management: farch "FeatureName" -sm "nameStateManagement" -bloc|-getx|-provider');
  }

  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      printUsage();
      return;
    }

    final featureName = arguments[0];

    if (featureName == 'list') {
      await _listFeatures();
      return;
    }

    if (arguments.length > 1) {
      if (arguments.contains('-sm')) {
        final architecture = await _getCurrentArchitecture(featureName);
        if (architecture != null) {
          await _handleOption(arguments, featureName);
          return;
        }
      }
      
      if (_featureExists(featureName)) {
        await _handleOption(arguments, featureName);
        return;
      }
    }

    if (_featureExists(featureName) && arguments.length == 1) {
      Logger.error('Feature "$featureName" already exists.');
      return;
    }

    if (arguments.length > 1 && (arguments[1] == '-mvc' || arguments[1] == '-mvvm' || arguments[1] == '-clean')) {
      String architecture = arguments[1].substring(1);
      String? stateManagement = await _promptForStateManagement();
      String? customClassName;
      
      if (stateManagement != null) {
        customClassName = _promptForCustomClassName();
      }

      await GetItManager.manageGetIt(featureName, stateManagement, architecture);
      _createFeatureStructure(featureName, stateManagement, customClassName, architecture);
      Logger.success('Feature "$featureName" created successfully with $architecture architecture');
      return;
    }

    if (arguments.length > 1) {
      await _handleOption(arguments, featureName);
      return;
    }

    String? architecture = await _promptForArchitecture();
    String? stateManagement = await _promptForStateManagement();
    String? customClassName;
    
    if (stateManagement != null) {
      customClassName = _promptForCustomClassName();
    }

    await GetItManager.manageGetIt(featureName, stateManagement, architecture);
    _createFeatureStructure(featureName, stateManagement, customClassName, architecture);
    Logger.success('Feature "$featureName" created successfully');
  }

  Future<void> _listFeatures() async {
    final featuresDirectory = Directory('lib/features');
    if (!featuresDirectory.existsSync()) {
      print('The "lib/features" directory does not exist.');
      return;
    }

    final features = featuresDirectory.listSync().whereType<Directory>();
    if (features.isEmpty) {
      print('No features found.');
      return;
    }

    print('List of available features:');
    for (var feature in features) {
      final featureName = feature.path.split('/').last.replaceAll("features\\", '');
      print('\x1B[32m$featureName\x1B[0m');
    }
  }

  Future<String?> _promptForStateManagement() async {
    print('\nChoose a state management solution:');
    print('1. Bloc');
    print('2. GetX');
    print('3. Provider');
    stdout.write('Enter your choice (1-3): ');
    
    final choice = stdin.readLineSync()?.trim();
    switch (choice) {
      case '1': return 'bloc';
      case '2': return 'getx';
      case '3': return 'provider';
      default: return null;
    }
  }

  String? _promptForCustomClassName() {
    stdout.write('Enter a custom class name for state management (optional): ');
    return stdin.readLineSync()?.trim();
  }

  Map<String, String>? _parseStateManagementArguments(List<String> arguments) {
    final index = arguments.indexOf('-sm');
    if (index + 1 >= arguments.length) {
      print('State management option specified without a valid name.');
      return null;
    }

    final customClassName = arguments[index + 1];
    final smType = arguments.firstWhere(
      (arg) => ['-bloc', '-getx', '-provider'].contains(arg),
      orElse: () => '',
    ).replaceFirst('-', '');

    if (smType.isEmpty) {
      print('State management type is missing or invalid. Use -bloc, -getx, or -provider.');
      return null;
    }

    return {'type': smType, 'name': customClassName};
  }

  Future<void> _handleOption(List<String> arguments, String featureName) async {
    final architecture = await _getCurrentArchitecture(featureName);
    switch (architecture) {
      case 'mvc':
        await MVCArchitecture.handleOption(arguments, featureName);
        break;
      case 'mvvm':
        await MVVMArchitecture.handleOption(arguments, featureName);
        break;
      case 'clean':
        await CleanArchitecture.handleOption(arguments, featureName);
        break;
      default:
        print('Unknown architecture. Using Clean Architecture as default.');
        await CleanArchitecture.handleOption(arguments, featureName);
    }
  }

  Future<String> _getCurrentArchitecture(String featureName) async {
    if (Directory('lib/features/$featureName/controllers').existsSync()) {
      return 'mvc';
    } else if (Directory('lib/features/$featureName/viewmodels').existsSync()) {
      return 'mvvm';
    } else {
      return 'clean';
    }
  }

  Future<String?> _promptForArchitecture() async {
    print('\nChoose an architecture:');
    print('1. MVC (Model-View-Controller)');
    print('2. MVVM (Model-View-ViewModel)');
    print('3. Clean Architecture');
    stdout.write('Enter your choice (1-3): ');
    
    final choice = stdin.readLineSync()?.trim();
    switch (choice) {
      case '1': return 'mvc';
      case '2': return 'mvvm';
      case '3': return 'clean';
      default: return null;
    }
  }

  void _createFeatureStructure(String featureName, String? stateManagement, [String? customClassName, String? architecture]) {
    if (architecture == null) {
      Logger.error('Invalid architecture choice. Using Clean Architecture as default.');
      architecture = 'clean';
    }

    final subdirectories = _getSubdirectoriesForArchitecture(architecture);
    
    for (var subdir in subdirectories) {
      Directory('lib/features/$featureName/$subdir').createSync(recursive: true);
    }

      GetItManager.manageGetIt(featureName, stateManagement, architecture);

    switch (architecture) {
      case 'mvc':
        MVCArchitecture.createStructure(featureName, stateManagement, customClassName);
        break;
      case 'mvvm':
        MVVMArchitecture.createStructure(featureName, stateManagement, customClassName);
        break;
      case 'clean':
        CleanArchitecture.createStructure(featureName, stateManagement, customClassName);
        break;
    }
  }

  List<String> _getSubdirectoriesForArchitecture(String architecture) {
    switch (architecture) {
      case 'mvc':
        return MVCArchitecture.getSubdirectories();
      case 'mvvm':
        return MVVMArchitecture.getSubdirectories();
      case 'clean':
        return CleanArchitecture.getSubdirectories();
      default:
        return [];
    }
  }

  bool _featureExists(String featureName) {
    final featureDir = Directory('lib/features/$featureName');
    return featureDir.existsSync();
  }
}
