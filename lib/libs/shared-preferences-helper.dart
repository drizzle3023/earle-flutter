import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:Earle/libs/global.dart';

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _api_token = "api_token";
  static final String _user_name = "user_name";
  static final String _user_email = "user_email";
  static final String _user_id = "user_id";
  static final String _company_id = "company_id";
  static final String _user_role = "user_role";

  static Future<String> getApiToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_api_token) ?? '';
  }

  static Future<void> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Globals.shared.apiToken = prefs.getString(_api_token) ?? '';
    Globals.shared.userId = prefs.getInt(_user_id) ?? 0;
    Globals.shared.userName = prefs.getString(_user_name) ?? '';
    Globals.shared.userEmail = prefs.getString(_user_email) ?? '';
    Globals.shared.companyId = prefs.getInt(_company_id) ?? 0;
    Globals.shared.userRole = EnumToString.fromString(UserRole.values, prefs.getString(_user_role));
  }

  static Future<void> setUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(_api_token, Globals.shared.apiToken);
    prefs.setInt(_user_id, Globals.shared.userId);
    prefs.setString(_user_name, Globals.shared.userName);
    prefs.setString(_user_email, Globals.shared.userEmail);
    prefs.setInt(_company_id , Globals.shared.companyId);
    prefs.setString(_user_role, EnumToString.parse(Globals.shared.userRole));
  }

  static Future<void> clearStoredData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove(_api_token);
    //prefs.remove(_user_email);
    prefs.remove(_user_name);
    prefs.remove(_user_id);
    prefs.remove(_company_id);
    prefs.remove(_user_role);

  }

}