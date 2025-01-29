import 'dart:convert';
import '../../../../core/utils/utility.dart';
import '../../../../core/content.dart';
import '../../../../core/base/base_manager.dart';
import '../../../../core/utils/logger.dart';
import '../../../json2dart/json_to_dart.dart';

class ModelAndEntityManager extends BaseManager {
  @override
  Future<void> create(String featureName, String name, [bool useJson2Dart = false]) async {
    final modelFilePath = Utility.getFilePath(
      featureName, 
      'data/models', 
      '${name.toLowerCase()}_model'
    );
    final entityFilePath = Utility.getFilePath(
      featureName, 
      'domain/entities', 
      '${name.toLowerCase()}_entity'
    );

    try {
      if (useJson2Dart) {
        await _createFromJson(name, entityFilePath, modelFilePath);
      } else {
        await _createDefault(name, entityFilePath, modelFilePath);
      }
    } catch (e) {
      Logger.error('Failed to create model and entity: $e');
      rethrow;
    }
  }

  Future<void> _createFromJson(String name, String entityFilePath, String modelFilePath) async {
    final jsonToDartConverter = JsonToDartConverter();
    final jsonString = Utility.readFile(modelFilePath);
    
    try {
      final json = jsonDecode(jsonString);
      final contentDart = jsonToDartConverter.convert(
        name, 
        json, 
        ArchitectureType.CLEAN
      );

      final contentEntity = contentDart.entity ?? Content.entityContent(name);
      
      Utility.writeFile(entityFilePath, contentEntity);
      Utility.writeFile(modelFilePath, contentDart.model);
      await Utility.formatFile(modelFilePath);
      await Utility.formatFile(entityFilePath);
      
      Logger.success('File "$name" has been successfully converted from JSON to Dart.');
    } catch (e) {
      if (e is FormatException) {
        Logger.error('The input must be in JSON format. Please check your input file.');
      } else {
        Logger.error('Failed to convert JSON to Dart');
      }
      rethrow;
    }
  }

  Future<void> _createDefault(String name, String entityFilePath, String modelFilePath) async {
     Utility.writeFile(entityFilePath, Content.entityContent(name));
     Utility.writeFile(modelFilePath, Content.modelContent(name));
    Logger.success('Model and entity "$name" created successfully');
  }
}
