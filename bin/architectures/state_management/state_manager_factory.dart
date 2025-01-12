import 'state_manager.dart';

class StateManagerFactory {
  static Future<void> createStateManagement(
    String architecture,
    String featureName,
    String stateManagement,
    [String? customClassName]
  ) async {
    switch (architecture.toLowerCase()) {
      case 'mvc':
      case 'mvvm':
      case 'clean':
        await StateManager.createStateManagementFiles(
          featureName, 
          stateManagement, 
          customClassName,
          architecture
        );
        break;
      default:
        print('Unknown architecture: $architecture');
    }
  }
} 