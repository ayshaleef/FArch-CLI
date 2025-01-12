import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVCControllerManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'controllers', 
      '${name.toLowerCase()}_controller'
    );
    
    Utility.writeFile(filePath, Content.getMVCControllerContent(className));
    Logger.success('MVC Controller "$name" created successfully.');
  }
} 