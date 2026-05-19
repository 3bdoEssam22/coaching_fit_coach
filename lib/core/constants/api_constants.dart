class ApiConstants {
  static const String baseUrl = "http://192.168.1.3:5000";

  // Auth
  static const String registerCoach = "/api/Auth/register/coach";
  static const String login = "/api/Auth/login";
  static const String refresh = "/api/Auth/refresh";
  static const String revoke = "/api/Auth/revoke";
  static const String getMe = "/api/Auth/me";
  static const String confirmEmail = "/api/Auth/confirm-email";
  static const String resendConfirmation = "/api/Auth/resend-confirmation";

  // Coach Profile
  static const String coachProfile = "/api/CoachProfile";
  static const String getMyProfile = "/api/CoachProfile/me";

  // Coach Certificates
  static const String coachCertificate = "/api/CoachCertificate";
  static const String myCertificates = "/api/CoachCertificate/me";
}
