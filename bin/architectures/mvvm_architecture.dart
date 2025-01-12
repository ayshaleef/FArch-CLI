import 'state_management/state_manager.dart';
import 'mvvm/model_manager.dart';
import 'mvvm/view_manager.dart';
import 'mvvm/viewmodel_manager.dart';
import 'mvvm/service_manager.dart';
import 'mvvm/repository_manager.dart';
import '../utils/logger.dart';

class MVVMArchitecture {
  static final _modelManager = MVVMModelManager();
  static final _viewManager = MVVMViewManager();
  static final _viewModelManager = MVVMViewModelManager();
  static final _serviceManager = MVVMServiceManager();
  static final _repositoryManager = MVVMRepositoryManager();

  static void createStructure(String featureName, String? stateManagement, String? customClassName) {
    // Create basic MVVM structure files
    _modelManager.create(featureName, featureName);
    _viewManager.create(featureName, featureName);
    _serviceManager.create(featureName, featureName);
    _repositoryManager.create(featureName, featureName);

    // Create ViewModel with selected state management
    if (stateManagement != null) {
      StateManager.createStateManagementFiles(featureName, stateManagement, customClassName, 'mvvm');
    } else {
      _viewModelManager.create(featureName, featureName);
    }
  }

  static List<String> getSubdirectories() {
    return [
      'models',
      'views',
      'viewmodels',
      'services',
      'repositories',
    ];
  }

  static Future<void> handleOption(List<String> arguments, String featureName) async {
    if (arguments.contains('-sm')) {
      final smIndex = arguments.indexOf('-sm');
      if (smIndex + 1 >= arguments.length) {
        print('State management name is required after -sm flag');
        return;
      }

      final smName = arguments[smIndex + 1];
      String? smType;
      
      if (arguments.contains('-bloc')) smType = 'bloc';
      else if (arguments.contains('-getx')) smType = 'getx';
      else if (arguments.contains('-provider')) smType = 'provider';
      
      if (smType == null) {
        print('Please specify state management type: -bloc, -getx, or -provider');
        return;
      }

      await StateManager.createStateManagementFiles(featureName, smType, smName, 'mvvm');
      return;
    }

    final option = arguments[1];
    final name = arguments[2];
    
    switch (option) {
      case '-m':
        await _modelManager.create(featureName, name);
        break;
      case '-vm':
        await _viewModelManager.create(featureName, name);
        break;
      case '-v':
        await _viewManager.create(featureName, name);
        break;
      case '-s':
        await _serviceManager.create(featureName, name);
        break;
      case '-r':
        await _repositoryManager.create(featureName, name);
        break;
      default:
        Logger.error('Invalid MVVM option. Use -m (model), -vm (viewmodel), -v (view), -s (service), or -r (repository).');
    }
  }
} 