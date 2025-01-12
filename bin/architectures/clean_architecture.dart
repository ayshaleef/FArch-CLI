import 'clean_architecture/usecase_manager.dart';
import 'clean_architecture/model_and_entity_manager.dart';
import 'clean_architecture/repository_manager.dart';
import 'clean_architecture/data_source_manager.dart';
import 'state_management/state_manager.dart';
import '../get_it_manager.dart';
import '../utils/logger.dart';

class CleanArchitecture {
  static void createStructure(String featureName, String? stateManagement, String? customClassName) {
    RepositoryManager().create(featureName, featureName);
    ModelAndEntityManager().create(featureName, featureName);
    UseCaseManager().create(featureName, featureName);
    DataSourceManager().create(featureName, featureName);

    if (stateManagement != null) {
      StateManager.createStateManagementFiles(featureName, stateManagement, customClassName, 'clean');
    }
  }

  static List<String> getSubdirectories() {
    return [
      'data/models',
      'data/repositories',
      'data/data_sources',
      'domain/entities',
      'domain/repositories',
      'domain/usecases',
      'presentation/pages',
      'presentation/widgets',
      'presentation/manager',
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

      await StateManager.createStateManagementFiles(featureName, smType, smName, 'clean');
      GetItManager.registerStateManagement(featureName, smName, smType);
      return;
    }

    final option = arguments[1];
    final name = arguments[2];
    
    switch (option) {
      case '-usecase':
      case '-u':
        await UseCaseManager().create(featureName, name);
        await GetItManager.registerUseCase(featureName, name);
        break;
      case '-m':
        await ModelAndEntityManager().create(featureName, name);
        break;
      case '-r':
      case '-repository':
        await RepositoryManager().create(featureName, name);
        await GetItManager.registerRepository(featureName, name);

        break;
      case '-d':
      case '-data':
        await DataSourceManager().create(featureName, name);
        await GetItManager.registerDataSource(featureName, name);

        break;
      default:
      Logger.error('Invalid Clean Architecture option. Use -u (usecase), -m (model), -r (repository), -sm (state management bloc || getx || provider), or -d (data source).');
    }
  }
} 