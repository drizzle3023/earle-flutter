import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';

import '../models/models.dart';

class Globals {

  static final Globals shared = Globals();

  Globals() {}

  static List<Company> glb_companies = [];
  static List<JobNumber> glb_jobnumbers = [];
  static Map<int, Company> glb_companies_with_id = {};
  static Map<int, JobNumber> glb_jobnumbers_with_id = {};

  int userId;
  String apiToken;
  String userName;
  String userEmail;
  UserRole userRole;
  int companyId;

  Map<MsgType, String> errorMsgs = {
    MsgType.FAIL: "Failed",
    MsgType.INVALID_TOKEN: "Your token is invalid",
    MsgType.TOKEN_EXPIRED: "Your token is expired",
    MsgType.TOKEN_NOT_FOUND: "Token not found.",
    MsgType.INVALID_PARAMS: "Please input your email and password correctly",
    MsgType.ERROR_GENERATE_API_TOKEN: "ERROR_GENERATE_API_TOKEN",
    MsgType.INVALID_USER: "There is no such user or password is not correct"
  };

  String getErrorMessage(MsgType msgType) {
    return errorMsgs[msgType];
  }

  Map<String, Object> searchClause = {};

  void showToast(BuildContext context, String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}

enum MsgType {
  SUCCESS,
  FAIL,
  INVALID_TOKEN,
  TOKEN_EXPIRED,
  TOKEN_NOT_FOUND,
  INVALID_PARAMS,
  ERROR_GENERATE_API_TOKEN,
  INVALID_USER
}

enum UserRole {
  SUPER,
  NORMAL
}