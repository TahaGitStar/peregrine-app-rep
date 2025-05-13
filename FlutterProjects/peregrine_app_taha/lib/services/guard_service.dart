import 'package:peregrine_app_taha/models/guard_models.dart';
import 'package:peregrine_app_taha/services/auth_service.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
// For actual API implementation, uncomment these:
// import 'dart:convert';
// import 'package:http/http.dart' as http;

/// Service for handling guard-related operations
class GuardService {
  // API endpoints - to be configured based on actual backend
  // These will be used when implementing the actual API calls
  // ignore: unused_field
  static const String _baseUrl = 'https://api.example.com'; // Replace with actual API URL
  // ignore: unused_field
  static const String _guardsEndpoint = '/client/guards';
  // ignore: unused_field
  static const String _guardDetailsEndpoint = '/client/guards/';
  
  /// Get all guards assigned to the client
  static Future<GuardsResponse> getAssignedGuards() async {
    try {
      AppLogger.i('Fetching assigned guards');
      
      // Get auth token for API request
      final token = await AuthService.getAuthToken();
      if (token == null) {
        return GuardsResponse.error('غير مصرح لك بالوصول. الرجاء تسجيل الدخول مرة أخرى.');
      }
      
      // TODO: Replace with actual API call when backend is ready
      // Example of how the API call would be structured:
      /*
      final response = await http.get(
        Uri.parse('$_baseUrl$_guardsEndpoint'),
        headers: {
          'Authorization': token.authorizationHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return GuardsResponse.fromJson(responseData);
      } else {
        // Handle error responses
        final errorData = jsonDecode(response.body);
        return GuardsResponse.error(errorData['message'] ?? 'Failed to fetch guards');
      }
      */
      
      // Temporary mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock response with sample data
      return GuardsResponse(
        guards: _getMockGuards(),
        success: true,
        message: 'تم جلب الحراس بنجاح',
        total: 3,
      );
    } catch (e) {
      AppLogger.e('Error fetching guards: $e');
      return GuardsResponse.error('حدث خطأ أثناء جلب الحراس: $e');
    }
  }
  
  /// Get details for a specific guard
  static Future<Guard?> getGuardDetails(String guardId) async {
    try {
      AppLogger.i('Fetching details for guard: $guardId');
      
      // Get auth token for API request
      final token = await AuthService.getAuthToken();
      if (token == null) {
        AppLogger.e('Auth token not found');
        return null;
      }
      
      // TODO: Replace with actual API call when backend is ready
      // Example of how the API call would be structured:
      /*
      final response = await http.get(
        Uri.parse('$_baseUrl$_guardDetailsEndpoint$guardId'),
        headers: {
          'Authorization': token.authorizationHeader,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Guard.fromJson(responseData);
      } else {
        // Handle error responses
        AppLogger.e('Failed to fetch guard details: ${response.statusCode}');
        return null;
      }
      */
      
      // Temporary mock implementation
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the guard in mock data
      final mockGuards = _getMockGuards();
      return mockGuards.firstWhere(
        (guard) => guard.id == guardId,
        orElse: () => mockGuards.first, // Return first guard if not found
      );
    } catch (e) {
      AppLogger.e('Error fetching guard details: $e');
      return null;
    }
  }
  
  /// Get mock guards data for development
  static List<Guard> _getMockGuards() {
    // Create a replacement guard
    final replacementGuard = Guard(
      id: 'g004',
      name: 'سعيد محمد',
      badgeNumber: 'B789',
      phoneNumber: '0512345678',
      profileImageUrl: null, // No image for mock data
      specialization: 'حماية شخصية',
      isActive: true,
      schedule: [
        WorkSchedule(
          dayOfWeek: 1,
          startTime: '08:00',
          endTime: '16:00',
          location: 'المبنى الرئيسي',
        ),
        WorkSchedule(
          dayOfWeek: 3,
          startTime: '08:00',
          endTime: '16:00',
          location: 'المبنى الرئيسي',
        ),
        WorkSchedule(
          dayOfWeek: 5,
          startTime: '08:00',
          endTime: '16:00',
          location: 'المبنى الرئيسي',
        ),
      ],
      leaveDays: [],
      replacementGuard: null,
    );
    
    return [
      Guard(
        id: 'g001',
        name: 'أحمد علي',
        badgeNumber: 'A123',
        phoneNumber: '0501234567',
        profileImageUrl: null, // No image for mock data
        specialization: 'أمن عام',
        isActive: true,
        schedule: [
          WorkSchedule(
            dayOfWeek: 1,
            startTime: '08:00',
            endTime: '16:00',
            location: 'المدخل الرئيسي',
          ),
          WorkSchedule(
            dayOfWeek: 2,
            startTime: '08:00',
            endTime: '16:00',
            location: 'المدخل الرئيسي',
          ),
          WorkSchedule(
            dayOfWeek: 3,
            startTime: '08:00',
            endTime: '16:00',
            location: 'المدخل الرئيسي',
          ),
          WorkSchedule(
            dayOfWeek: 4,
            startTime: '08:00',
            endTime: '16:00',
            location: 'المدخل الرئيسي',
          ),
          WorkSchedule(
            dayOfWeek: 5,
            startTime: '08:00',
            endTime: '16:00',
            location: 'المدخل الرئيسي',
          ),
        ],
        leaveDays: [
          LeaveDay(
            startDate: DateTime.now().add(const Duration(days: 5)),
            endDate: DateTime.now().add(const Duration(days: 10)),
            reason: 'إجازة سنوية',
            status: 'approved',
            replacementGuard: replacementGuard,
          ),
        ],
        replacementGuard: null,
      ),
      Guard(
        id: 'g002',
        name: 'محمد خالد',
        badgeNumber: 'A456',
        phoneNumber: '0509876543',
        profileImageUrl: null, // No image for mock data
        specialization: 'مراقبة كاميرات',
        isActive: true,
        schedule: [
          WorkSchedule(
            dayOfWeek: 1,
            startTime: '16:00',
            endTime: '00:00',
            location: 'غرفة المراقبة',
          ),
          WorkSchedule(
            dayOfWeek: 2,
            startTime: '16:00',
            endTime: '00:00',
            location: 'غرفة المراقبة',
          ),
          WorkSchedule(
            dayOfWeek: 3,
            startTime: '16:00',
            endTime: '00:00',
            location: 'غرفة المراقبة',
          ),
          WorkSchedule(
            dayOfWeek: 4,
            startTime: '16:00',
            endTime: '00:00',
            location: 'غرفة المراقبة',
          ),
          WorkSchedule(
            dayOfWeek: 5,
            startTime: '16:00',
            endTime: '00:00',
            location: 'غرفة المراقبة',
          ),
        ],
        leaveDays: [
          LeaveDay(
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 3)),
            reason: 'إجازة مرضية',
            status: 'approved',
            replacementGuard: replacementGuard,
          ),
        ],
        replacementGuard: null,
      ),
      Guard(
        id: 'g003',
        name: 'عبدالله محمد',
        badgeNumber: 'B123',
        phoneNumber: '0507654321',
        profileImageUrl: null, // No image for mock data
        specialization: 'أمن المرافق',
        isActive: true,
        schedule: [
          WorkSchedule(
            dayOfWeek: 6,
            startTime: '08:00',
            endTime: '20:00',
            location: 'المبنى الفرعي',
          ),
          WorkSchedule(
            dayOfWeek: 7,
            startTime: '08:00',
            endTime: '20:00',
            location: 'المبنى الفرعي',
          ),
        ],
        leaveDays: [],
        replacementGuard: null,
      ),
    ];
  }
}