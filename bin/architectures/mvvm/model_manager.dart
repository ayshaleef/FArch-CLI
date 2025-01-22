import 'dart:convert';

import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';
import '../../json2dart/json_to_dart.dart';

class MVVMModelManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name, [bool useJson2Dart = false]) async {
    final filePath = Utility.getFilePath(
      featureName, 
      'models', 
      '${name.toLowerCase()}_model'
    );

    try {
      if (useJson2Dart) {
        await _createFromJson(name, filePath);
      } else {
        await _createDefault(name, filePath);
      }
    } catch (e) {
      Logger.error('Failed to create model: $e');
      rethrow;
    }
  }

  Future<void> _createFromJson(String name, String filePath) async {
    final jsonToDartConverter = JsonToDartConverter();
    final json = Utility.readFile(filePath);
    
    final contentDart = jsonToDartConverter.convert(
      name, 
      jsonDecode(json), 
      ArchitectureType.MVVM
    );
    
    Utility.writeFile(filePath, contentDart.model);
    await Utility.formatFile(filePath);
    Logger.success('File "$name" has been successfully converted from JSON to Dart.');
  }

  Future<void> _createDefault(String name, String filePath) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    Utility.writeFile(filePath, Content.getMVVMModelContent(className));
    Logger.success('MVVM Model "$name" created successfully.');
  }
} 