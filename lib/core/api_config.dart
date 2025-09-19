/// API Configuration for the application
class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'http://192.168.2.52:3000/api';
  static const String _prodBaseUrl = 'https://api.yourcompany.com';
  
  // Current environment
  static const bool _isDevelopment = true;
  
  /// Get the current base URL based on environment
  static String get baseUrl => _isDevelopment ? _devBaseUrl : _prodBaseUrl;
  
  // API Endpoints
  static const String productsEndpoint = '/products';
  static const String dealersEndpoint = '/dealers';
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Error messages
  static const String connectionErrorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
  static const String timeoutErrorMessage = 'การเชื่อมต่อหมดเวลา';
  static const String serverErrorMessage = 'เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่อีกครั้ง';
  static const String unknownErrorMessage = 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
  
  // Logging
  static const bool enableLogging = true;
}