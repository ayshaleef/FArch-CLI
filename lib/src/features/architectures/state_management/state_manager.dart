import '../../../core/utils/utility.dart';
import '../../../core/content.dart';
import '../../../core/utils/logger.dart';
class StateManager {

  static Future<void> createStateManagementFiles(String featureName, String stateManagement, [String? customClassName, String? architecture]) async{
    String name= customClassName != null && customClassName.isNotEmpty ? customClassName : featureName;
    architecture = architecture?.toLowerCase() ?? 'clean';
    switch (stateManagement.toLowerCase()) {
      case 'bloc':
      if(await Utility.addDependency('flutter_bloc'))
      {
        _createBlocFiles(featureName , name , architecture );
      }
        break;
      case 'getx':
        if (await Utility.addDependency('get')) {
          _createGetXFiles(featureName, name, architecture);
        }
        break;
      case 'provider':
        if (await Utility.addDependency('provider')) {
          _createProviderFiles(featureName, name, architecture);
        }
        break;
      default:
        print('Invalid state management option: $stateManagement');
    }
  }

static _createBlocFiles(String featureName, String name, String architecture) {
  name = Utility.convertCase(name, toCamelCase: true);
  final fileName = Utility.convertCase(name, toCamelCase: false);
  final basePath = architecture == 'mvc' 
        ? 'controllers'
        : architecture == 'mvvm'
            ? 'viewmodels'
            : 'presentation/manager/bloc/${fileName.toLowerCase()}';

  final blocFilePath = Utility.getFilePath(featureName, basePath, '${fileName.toLowerCase()}_bloc');
  Utility.writeFile(blocFilePath, Content.blocContent(name, fileName));
  final eventFilePath = Utility.getFilePath(featureName, basePath, '${fileName.toLowerCase()}_event');
  Utility.writeFile(eventFilePath, Content.eventContent(name, fileName));
  final stateFilePath = Utility.getFilePath(featureName, basePath, '${fileName.toLowerCase()}_state');
  Utility.writeFile(stateFilePath, Content.stateContent(name, fileName));
  if (architecture == 'mvc') {
    _updateMVCViewForBloc(featureName, name);
  } else if (architecture == 'mvvm') {
    _updateMVVMViewForBloc(featureName, name);
  }
  Logger.success('Bloc files (bloc, event, state) for "$featureName" created with state manager "$fileName".');
}

static void _updateMVCViewForBloc(String featureName, String name) {
  final viewPath = Utility.getFilePath(featureName, 'views', '${featureName.toLowerCase()}_view');
  final content = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/${name.toLowerCase()}_bloc.dart';

class ${name}View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${name}Bloc(),
      child: BlocBuilder<${name}Bloc, ${name}State>(
        builder: (context, state) {
          return Container(
            // TODO: Implement view
          );
        },
      ),
    );
  }
}
''';
  Utility.writeFile(viewPath, content);
}

static void _updateMVVMViewForBloc(String featureName, String name) {
  final viewPath = Utility.getFilePath(featureName, 'views', '${featureName.toLowerCase()}_view');
  final content = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/${name.toLowerCase()}_bloc.dart';

class ${name}View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ${name}Bloc(),
      child: BlocBuilder<${name}Bloc, ${name}State>(
        builder: (context, state) {
          return Container(
            // TODO: Implement view
          );
        },
      ),
    );
  }
}
''';
  Utility.writeFile(viewPath, content);
}

static void _updateMVVMViewForGetX(String featureName, String name) {
  final viewPath = Utility.getFilePath(featureName, 'views', '${featureName.toLowerCase()}_view');
  final content = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/${name.toLowerCase()}_controller.dart';

class ${name}View extends GetView<${name}Controller> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<${name}Controller>(
      init: ${name}Controller(),
      builder: (controller) {
        return Container(
          // TODO: Implement view
        );
      },
    );
  }
}
''';
  Utility.writeFile(viewPath, content);
}

  static void _createGetXFiles(String featureName, String name, String architecture) {
    name = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(name, toCamelCase: false);

    // Choose the appropriate path based on architecture
    final basePath = architecture == 'mvc' 
        ? 'controllers'
        : architecture == 'mvvm'
            ? 'viewmodels'
            : 'presentation/manager/controller';

    final controllerFilePath = Utility.getFilePath(
        featureName, 
        basePath, 
        '${fileName.toLowerCase()}_controller'
    );
    Utility.writeFile(controllerFilePath, Content.getxControllerContent(name));
    if (architecture == 'mvvm') {
      _updateMVVMViewForGetX(featureName, name);
    }
    
    Logger.success('GetX controller for "$featureName" created with state manager "$fileName".');
  }

  static void _createProviderFiles(String featureName, String name, String architecture) {
    name = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(name, toCamelCase: false);

    // Choose the appropriate path based on architecture
    final basePath = architecture == 'mvc' 
        ? 'controllers'
        : architecture == 'mvvm'
            ? 'viewmodels'
            : 'presentation/manager/provider';

    final providerFilePath = Utility.getFilePath(
        featureName, 
        basePath, 
        '${fileName.toLowerCase()}_provider'
    );
    
    Utility.writeFile(providerFilePath, Content.providerContent(name));
    
    // Update the view if using MVVM
    if (architecture == 'mvvm') {
      _updateMVVMViewForProvider(featureName, name);
    }
    
    Logger.success('Provider for "$featureName" created with state manager "$fileName".');
  }

  static void _updateMVVMViewForProvider(String featureName, String name) {
    final viewPath = Utility.getFilePath(featureName, 'views', '${featureName.toLowerCase()}_view');
    final content = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/${name.toLowerCase()}_provider.dart';

class ${name}View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ${name}Provider(),
      child: Consumer<${name}Provider>(
        builder: (context, provider, child) {
          return Container(
            // TODO: Implement view
          );
        },
      ),
    );
  }
}
''';
    Utility.writeFile(viewPath, content);
  }

}

