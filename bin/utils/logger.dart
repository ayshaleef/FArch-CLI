/// Centralizes logging and user feedback
class Logger {
  static void success(String message) {
    print('\x1B[32m✅ - $message\x1B[0m');
  }

  static void error(String message) {
    print('\x1B[31m❌ - $message\x1B[0m');
  }

  static void info(String message) {
    print('\x1B[34mℹ️ $message\x1B[0m');
  }
} 