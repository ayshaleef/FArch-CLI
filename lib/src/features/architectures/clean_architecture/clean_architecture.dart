import 'manager/usecase_manager.dart';
import 'manager/model_and_entity_manager.dart';
import 'manager/repository_manager.dart';
import 'manager/data_source_manager.dart';
import '../state_management/state_manager.dart';
import '../../dependency_injection/get_it_manager.dart';
import '../../../core/utils/logger.dart';
import '../../../core/interfaces/architecture_interface.dart';

class CleanArchitecture implements IArchitecture {

  @override
  void createStructure(String featureName, String? stateManagement, String? customClassName) {
    RepositoryManager().create(featureName, featureName);
    ModelAndEntityManager().create(featureName, featureName);
    UseCaseManager().create(featureName, featureName);
    DataSourceManager().create(featureName, featureName);

    if (stateManagement != null) {
      StateManager.createStateManagementFiles(featureName, stateManagement, customClassName, 'clean');
    }
  }

  @override
  List<String> getSubdirectories() {
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
  
  @override
   Future<void> handleOption(List<String> arguments, String featureName) async {
    if (arguments.contains('-sm')) {
      final smIndex = arguments.indexOf('-sm');
      if (smIndex + 1 >= arguments.length) {
        print('State management name is required after -sm flag');
        return;
      }

      final smName = arguments[smIndex + 1];
      String? smType;
      
      if (arguments.contains('-bloc')) {
        smType = 'bloc';
      // ignore: curly_braces_in_flow_control_structures
      } else if (arguments.contains('-getx')) smType = 'getx';
      // ignore: curly_braces_in_flow_control_structures
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
        await UseCaseManager().create(featureName, name.replaceAll('_usecase', ""));
        await GetItManager.registerUseCase(featureName, name.replaceAll('_usecase', ""));
        break;
      case '-m':
        final useJson2Dart = arguments.contains('-j2d');
        await ModelAndEntityManager().create(featureName, name.replaceAll('_model', "").replaceAll('_entity', "") , useJson2Dart);
        break;
      case '-r':
      case '-repository':
        await RepositoryManager().create(featureName, name.replaceAll('_repository', ""));
        await GetItManager.registerRepository(featureName, name.replaceAll('_repository', ""));

        break;
      case '-d':
      case '-data':
        await DataSourceManager().create(featureName, name.replaceAll('_data_source', ""));
        await GetItManager.registerDataSource(featureName, name.replaceAll('_data_source', ""));

        break;
      default:
      Logger.error('Invalid Clean Architecture option. Use -u (usecase), -m (model), -r (repository), -sm (state management bloc || getx || provider), or -d (data source).');
    }
  }
} 