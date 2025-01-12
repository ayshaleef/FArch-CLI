import 'dart:io';
import '../../utility.dart';
import '../base/base_manager.dart';
import '../../content.dart';
import '../../utils/logger.dart';

class RepositoryManager extends BaseManager {


  @override
  Future<void> create(String featureName, String name) async {
    final repoFilePath = Utility.getFilePath(
        featureName, 'domain/repositories', '${name.toLowerCase()}_repository');
    final implFilePath = Utility.getFilePath(featureName, 'data/repositories',
        '${name.toLowerCase()}_repository_implement');
    if (File(repoFilePath).existsSync() || File(implFilePath).existsSync()) {
      print('Repository "$name" already exists.');
    }
    final className = Utility.convertCase(name, toCamelCase: true);
    final fileName = Utility.convertCase(className, toCamelCase: false);
    Utility.writeFile(repoFilePath, Content.repoContent(className));
    Utility.writeFile(implFilePath, Content.repoImplContent(className , fileName));
    Logger.success('Repository "$name" created successfully');

  
  }
}
