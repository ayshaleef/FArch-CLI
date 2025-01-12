import 'dart:io';
import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';
class ModelAndEntityManager extends BaseManager{
  @override
  Future<void> create(String featureName, String name) async{
    final modelFilePath = Utility.getFilePath(featureName, 'data/models', '${name.toLowerCase()}_model');
    final entityFilePath = Utility.getFilePath(featureName, 'domain/entities', '${name.toLowerCase()}_entity');

    if (File(modelFilePath).existsSync() || File(entityFilePath).existsSync()) {
      print('Model or entity "$name" already exists.');
      return;
    }
    Utility.writeFile(entityFilePath, Content.entityContent(name));
    Utility.writeFile(modelFilePath, Content.modelContent(name));
    Logger.success('Model and entity "$name" created successfully');
  
  
  }
 
}
