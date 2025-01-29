import '../../../../core/utils/utility.dart';
import '../../../../core/base/base_manager.dart';
import '../../../../core/utils/logger.dart';

class MVVMRepositoryManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    
    // Create repository interface
    final repositoryInterfacePath = Utility.getFilePath(
      featureName, 
      'repositories', 
      '${name.toLowerCase()}_repository'
    );
    
    final interfaceContent = '''
abstract class ${className}Repository {
  // TODO: Define repository interface methods
}
''';
    
    Utility.writeFile(repositoryInterfacePath, interfaceContent);
    
    // Create repository implementation
    final repositoryImplPath = Utility.getFilePath(
      featureName, 
      'repositories', 
      '${name.toLowerCase()}_implement_repository'
    );
    
    final implementationContent = '''
import '${name.toLowerCase()}_repository.dart';

class ${className}RepositoryImplement implements ${className}Repository {
  // TODO: Implement repository methods
}
''';
    
    Utility.writeFile(repositoryImplPath, implementationContent);
    Logger.success('MVVM Repository "$name" created successfully.');
  }
} 