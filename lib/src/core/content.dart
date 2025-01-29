import 'utils/utility.dart';

class Content {

  static String entityContent(String className) => '''
class ${Utility.convertCase(className, toCamelCase: true)}Entity {
  // TODO: Define entity properties here.
}
''';

    static modelContent (String className) => '''
import '../../domain/entities/${className.toLowerCase()}_entity.dart';

class ${Utility.convertCase(className, toCamelCase: true)}Model extends ${Utility.convertCase(className, toCamelCase: true)}Entity {
  // TODO: Add model properties here.
}
''';



static String repoContent(String className) => '''
abstract class ${Utility.convertCase(className, toCamelCase: true)}Repository {
  // TODO: Define repository methods here.
}
''';

    static String repoImplContent(String className , String fileName) => '''
import '../../domain/repositories/${fileName}_repository.dart';
import '../../data/data_sources/${fileName}_data_source.dart';

class ${className}RepositoryImplement implements ${className}Repository {
  final ${className}DataSource dataSource;
    ${className}RepositoryImplement({required this.dataSource});
}
''';

static String useCaseContent(String className , String repositoryFileName , String repositoryClassName)=>'''
import '../../domain/repositories/${repositoryFileName}_repository.dart';

class ${className}UseCase {
  final ${repositoryClassName}Repository repository;
  ${className}UseCase({required this.repository});
  
}

''';


static String dataSourceContent(String className) => '''
abstract class ${className}DataSource {
  // TODO: Define DataSource methods here.
}

class ${className}DataSourceImplement implements ${className}DataSource {
}
''';


//Bloc Content :

static String blocContent (String className , String fileName)=>'''
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '${fileName}_event.dart';
part '${fileName}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc() : super(${className}Initial()) {
    on<${className}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
''';


static String eventContent (String className , String fileName)=>'''

part of '${fileName}_bloc.dart';

@immutable
sealed class ${className}Event {}

''';

static String stateContent (String className , String fileName)=>'''
part of '${fileName}_bloc.dart';

@immutable
sealed class ${className}State {}

final class ${className}Initial extends ${className}State {}

''';

static String getxControllerContent(String className) => '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  // TODO: Add your observable variables here
  
  // TODO: Add your methods here
}
''';

static String providerContent(String className) => '''
import 'package:flutter/foundation.dart';

class ${className}Provider with ChangeNotifier {
  // TODO: Add your state variables here
  
  // TODO: Add your methods here
  
  void notifyListeners() {
    super.notifyListeners();
  }
}
''';

  static String getMVCModelContent(String className) => '''
class ${className}Model {
  // TODO: Add model properties and methods
}
''';

  static String getMVCControllerContent(String className) => '''
import '../models/${className}_model.dart';

class ${className}Controller {
  final ${className}Model _model = ${className}Model();
  
  // TODO: Add controller methods
}
''';

  static String getMVCViewContent(String className) => '''
import 'package:flutter/material.dart';
import '../controllers/${className.toLowerCase()}_controller.dart';

class ${className}View extends StatelessWidget {
  final ${className}Controller controller = ${className}Controller();

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Implement view
    );
  }
}
''';

  static String getMVVMModelContent(String className) => '''
class ${className}Model {
  // TODO: Add model properties and methods
}
''';

  static String getMVVMViewModelContent(String className) => '''
import 'package:flutter/foundation.dart';
import '../services/${className}_service.dart';
import '../models/${className}_model.dart';

class ${className}ViewModel extends ChangeNotifier {
  final ${className}Service _service = ${className}Service();
  final ${className}Model _model = ${className}Model();
  
  // Getter for the model
  ${className}Model get model => _model;
  
  // TODO: Add ViewModel properties and methods
  
  // Example of a method that updates state
  void updateState() {
    // Update your state here
    notifyListeners();
  }
}
''';

  static String getMVVMViewContent(String className) => '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/${className}_viewmodel.dart';

class ${className}View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ${className}ViewModel(),
      child: Consumer<${className}ViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            // TODO: Implement view
          );
        },
      ),
    );
  }
}
''';

  static String getMVVMServiceContent(String className) => '''
class ${className}Service {
  // TODO: Add service methods for API calls or business logic
}
''';

}