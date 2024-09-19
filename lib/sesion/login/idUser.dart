class UserSession {
  static final UserSession _instance = UserSession._internal();

  String? userId;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();
}
