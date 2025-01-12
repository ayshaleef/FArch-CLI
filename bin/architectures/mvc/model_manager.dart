import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVCModelManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'models', 
      '${name.toLowerCase()}_model'
    );
    
    Utility.writeFile(filePath, Content.getMVCModelContent(className));
    Logger.success('MVC Model "$name" created successfully.');
  }
} 