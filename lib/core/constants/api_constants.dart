class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:5000";

  // Auth
  static const String registerCoach = "/api/Auth/register/coach";
  static const String login = "/api/Auth/login";
  static const String getMe = "/api/Auth/me";
  static const String confirmEmail = "/api/Auth/confirm-email";
  static const String resendConfirmation = "/api/Auth/resend-confirmation";

  // Coach Profile
  static const String coachProfile = "/api/CoachProfile";
  static const String getMyProfile = "/api/CoachProfile/me";
}
