import '../interfaces/architecture_interface.dart';
import '../../features/architectures/clean_architecture/clean_architecture.dart';
import '../../features/architectures/mvvm/mvvm_architecture.dart';
import '../../features/architectures/mvc/mvc_architecture.dart';

class ArchitectureFactory {
  IArchitecture? getArchitectureHandler(String architecture) {
    switch (architecture) {
      case 'mvc':
        return MVCArchitecture();
      case 'mvvm':
        return MVVMArchitecture();
      case 'clean':
        return CleanArchitecture();
      default:
        return null;
    }
  }
}