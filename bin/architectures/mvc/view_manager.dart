import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVCViewManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'views', 
      '${name.toLowerCase()}_view'
    );
    
    Utility.writeFile(filePath, Content.getMVCViewContent(className));
    Logger.success('MVC View "$name" created successfully.');
  }
} 