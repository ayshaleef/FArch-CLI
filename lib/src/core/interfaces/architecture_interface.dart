abstract class IArchitecture {
  void createStructure(String featureName, String? stateManagement, String? customClassName);
  List<String> getSubdirectories();
  Future<void> handleOption(List<String> arguments, String featureName);
}