import 'dart:io';
import '../../utility.dart';
import '../base/base_manager.dart';
import 'repository_manager.dart';
import '../../get_it_manager.dart';
import '../../content.dart';
import '../../utils/logger.dart';

class UseCaseManager extends BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    String? repositoryClass;

    if (name.contains(":")) {
      List<String> nameWithRepository = name.split(':');
      name = nameWithRepository[0];
      repositoryClass = nameWithRepository[1];
      await RepositoryManager().create(featureName, repositoryClass);
      await GetItManager.registerRepository(featureName, repositoryClass);
    }

    final filePath = Utility.getFilePath(
        featureName, 'domain/usecases', '${name.toLowerCase()}_usecase');
    if (File(filePath).existsSync()) {
      print('Use case "$name" already exists.');
      return;
    }

    final className = Utility.convertCase(name, toCamelCase: true);

    final repositoryClassName =
        Utility.convertCase(repositoryClass ?? featureName, toCamelCase: true);
    final repositoryFileName =
        Utility.convertCase(repositoryClassName, toCamelCase: false);

    Utility.writeFile(
        filePath,
        Content.useCaseContent(
            className, repositoryFileName, repositoryClassName));

    Logger.success('Use case "$name" created successfully.');
  }
}
