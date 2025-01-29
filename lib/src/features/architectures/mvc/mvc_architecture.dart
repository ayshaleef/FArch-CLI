import '../state_management/state_manager.dart';
import 'manager/controller_manager.dart';
import 'manager/model_manager.dart';
import 'manager/view_manager.dart';
import '../../../core/utils/logger.dart';
import '../../../core/interfaces/architecture_interface.dart';

class MVCArchitecture implements IArchitecture{
  static final _controllerManager = MVCControllerManager();
  static final _modelManager = MVCModelManager();
  static final _viewManager = MVCViewManager();

  @override
  void createStructure(String featureName, String? stateManagement, String? customClassName) {
    // Create basic MVC structure files
    _modelManager.create(featureName, featureName);
    _viewManager.create(featureName, featureName);

    // Create controller with selected state management
    if (stateManagement != null) {
      StateManager.createStateManagementFiles(featureName, stateManagement, customClassName, 'mvc');
    } else {
      _controllerManager.create(featureName, featureName);
    }
  }


  @override
  List<String> getSubdirectories() {
    return [
      'models',
      'views',
      'controllers',
    ];
  }


  @override
  Future<void> handleOption(List<String> arguments, String featureName) async {
    if (arguments.contains('-sm')) {
      // Handle state management flag
      final smIndex = arguments.indexOf('-sm');
      if (smIndex + 1 >= arguments.length) {
        print('State management name is required after -sm flag');
        return;
      }

      final smName = arguments[smIndex + 1];
      String? smType;
      
      if (arguments.contains('-bloc')) {
        smType = 'bloc';
      } else if (arguments.contains('-getx'))
      {
        smType = 'getx';
      }
      else if (arguments.contains('-provider')) {
        smType = 'provider';
      }
      
      if (smType == null) {
        print('Please specify state management type: -bloc, -getx, or -provider');
        return;
      }
      await StateManager.createStateManagementFiles(featureName, smType, smName, 'mvc');
      return;
    }

    final option = arguments[1];
    final name = arguments[2];
  
    
    switch (option) {
      case '-m':
        final useJson2Dart = arguments.contains('-j2d');
        await _modelManager.create(featureName, name, useJson2Dart);
        break;

      case '-v':
        await _viewManager.create(featureName, name);
        break;
      default:
        Logger.error('Invalid MVC option. Use -m (model), -sm (controller State Management), or -v (view).');
    }
  }
} 