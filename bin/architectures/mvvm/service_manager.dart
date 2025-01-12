import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVVMServiceManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'services', 
      '${name.toLowerCase()}_service'
    );
    
    Utility.writeFile(filePath, Content.getMVVMServiceContent(className));
    Logger.success('MVVM Service "$name" created successfully.');
  }
} 