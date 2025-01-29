import 'dart:io';
import '../../../../core/base/base_manager.dart';
import '../../../../core/utils/utility.dart';
import '../../../../core/content.dart';
import '../../../../core/utils/logger.dart';

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
