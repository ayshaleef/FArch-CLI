import '../../utility.dart';
import '../../content.dart';
import '../base/base_manager.dart';
import '../../utils/logger.dart';

class MVVMViewModelManager implements BaseManager {
  @override
  Future<void> create(String featureName, String name) async {
    final className = Utility.convertCase(name, toCamelCase: true);
    final filePath = Utility.getFilePath(
      featureName, 
      'viewmodels', 
      '${name.toLowerCase()}_viewmodel'
    );
    
    Utility.writeFile(filePath, Content.getMVVMViewModelContent(className));
    Logger.success('MVVM ViewModel "$name" created successfully.');
  }
} 