import 'dart:io';
import '../base/base_manager.dart';
import '../../utility.dart';
import '../../content.dart';
import '../../utils/logger.dart';

class DataSourceManager extends BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final dataSourceFilePath = Utility.getFilePath(
        featureName, 'data/data_sources', '${name.toLowerCase()}_data_source');
    if (File(dataSourceFilePath).existsSync()) {
      print('Data Source "$name" already exists.');
    } else {
      final className = Utility.convertCase(name, toCamelCase: true);
      Utility.writeFile(dataSourceFilePath, Content.dataSourceContent(className));
      Logger.success('Data Source "$name" created successfully.');
    }
  }
}
