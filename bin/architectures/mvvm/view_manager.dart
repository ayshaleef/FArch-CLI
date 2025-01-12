import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVVMViewManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'views', 
      '${name.toLowerCase()}_view'
    );
    
    Utility.writeFile(filePath, Content.getMVVMViewContent(className));
    Logger.success('MVVM View "$name" created successfully.');
  }
} 