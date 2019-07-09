import 'package:enum_to_string/enum_to_string.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'models/models.dart' as Models;
import 'libs/constants.dart';
import 'libs/global.dart';

class ApiManager {
  static final ApiManager shared = ApiManager();

  String baseUrl = Constants.shared.baseApiUrl();  //'http://18.222.111.142/api';
  ApiManager() {}

  Future<MsgType> doLogin({String email, String password}) async {
    final response = await http.post(this.baseUrl + '/auth/login',
        body: {'email': email, 'password': password});
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      print(json);

      if (json['data'].length == 0) {
        return EnumToString.fromString(MsgType.values, json['message']);
      } else {
        Globals.shared.apiToken = 'earle ' + json['data']['api_token'];
        Globals.shared.userId = json['data']['user']['id'];
        Globals.shared.userName = json['data']['user']['name'];
        Globals.shared.userEmail = json['data']['user']['email'];
        Globals.shared.companyId = json['data']['user']['company_id'];
        Globals.shared.userRole = EnumToString.fromString(UserRole.values, json['data']['user']['role']);

        return MsgType.SUCCESS;
      }

    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>>fetchImages({int shownCount}) async {
    final response = await http.post(this.baseUrl + '/image/get', headers: {
      'X-API-TOKEN': Globals.shared.apiToken
    }, body: {'shownCount' : shownCount.toString()});

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      Map<String, dynamic> result = new HashMap();
      if (json['data'].length == 0) {
        result["message"] = EnumToString.fromString(MsgType.values, json['message']);
        return result;
      } else {

        List<Models.Image> res_imgs = [];
        List<dynamic> images = json["data"]["images"];

        for (var i = 0; i < images.length; i ++) {
          Models.Image img = Models.Image.fromJson(images[i]);
          img.user = Models.User.fromJson(images[i]['user']);
          res_imgs.add(img);
        }
        result['total'] = json["data"]["total"];
        result['images'] = res_imgs;
        result["message"] = MsgType.SUCCESS;

        return result;
      }
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<Map<String, dynamic>> doSearch(Map<String, Object> searchClause, int shownCount) async {

    final response = await http.post(this.baseUrl + '/search', headers: {
      'X-API-TOKEN': Globals.shared.apiToken
    },
        body: {
          'title' : searchClause["title"] ?? "",
          'route' : searchClause["route"] ?? "",
          'comment': searchClause["comment"] ?? "",
          'job_id': searchClause["job_id"] == null ? "0" : searchClause["job_id"].toString(),
          'start_date': searchClause["start_date"] == null ? "0" : searchClause["start_date"].toString(),
          'end_date': searchClause["end_date"] == null? "0" : searchClause["end_date"].toString(),
          'shown_count': shownCount.toString()
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      Map<String, dynamic> result = new HashMap();
      if (json['data'].length == 0) {
        result["message"] = EnumToString.fromString(MsgType.values, json['message']);
        return result;
      } else {

        List<Models.Image> res_imgs = [];
        List<dynamic> images = json["data"]["images"];

        for (var i = 0; i < images.length; i ++) {
          Models.Image img = Models.Image.fromJson(images[i]);
          img.user = Models.User.fromJson(images[i]['user']);
          res_imgs.add(img);
        }
        result['total'] = json["data"]["total"];
        result['images'] = res_imgs;
        result["message"] = MsgType.SUCCESS;

        return result;
      }

    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<MsgType> doUpload({File file, String lat, String lng, String title, int jobNo_id, String route,
    String asset, String comment, String urgency, int upload_timestamp}) async {

    var uri = Uri.parse(this.baseUrl + '/image/upload');
    var request = new http.MultipartRequest('POST', uri);
    final length = await file.length();

    request.fields['lat'] = lat;
    request.fields['lan'] = lng;
    request.fields['title'] = title;
    request.fields['jobNo_id'] = jobNo_id.toString();
    request.fields['route'] = route;
    request.fields['asset'] = asset;
    request.fields['comment'] = comment;
    request.fields['urgency'] = urgency;
    request.fields['upload_timestamp'] = upload_timestamp.toString();

    var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(file.path));
    request.files.add(multipartFile);
    //contentType: new MediaType('image', 'png'));

    //request.files.add(new http.MultipartFile("image", file.openRead(), length));

    Map<String, String> headers = {'X-API-TOKEN': Globals.shared.apiToken};
    request.headers.addAll(headers);
    //request.headers['X-API-TOKEN'] = this.apiToken;
    http.Response response = await http.Response.fromStream(await request.send());

    //var response = await request.send();
    print(request);
    print(request.toString());

    if (response.statusCode == 200) {
     // var s = "1";
      Map<String, dynamic> json = jsonDecode(response.body);

      print(json);
      return MsgType.SUCCESS;
    } else {
      return MsgType.FAIL;
    }

  }

  Future<MsgType> updateImage({String lat, String lng, String title, int jobNo_id, String route,
    String asset, String comment, String urgency, int upload_timestamp, int image_id}) async {

    final response = await http.post(this.baseUrl + '/image/update', headers: {
      'X-API-TOKEN': Globals.shared.apiToken
    },
        body: {
          'lat': lat,
          'lan': lng,
          'title' : title,
          'route' : route,
          'asset': asset,
          'comment': comment,
          'job_id': jobNo_id.toString(),
          'urgency': urgency,
          'upload_timestamp': upload_timestamp.toString(),
          'image_id': image_id.toString()
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      print(json);
      return MsgType.SUCCESS;
    } else {
      return MsgType.FAIL;
    }

  }

  Future<MsgType>getJobNumbers() async {
    final response = await http.post(this.baseUrl + '/jobnumbers/get', headers: {
      'X-API-TOKEN': Globals.shared.apiToken
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      if (json['data'].length == 0) {
        return EnumToString.fromString(MsgType.values, json['message']);
      } else {
        List<dynamic> jobnumber_array = json["data"]["jobnumbers"];

        Globals.glb_jobnumbers.clear();
        for (var i = 0; i < jobnumber_array.length; i ++) {
          Globals.glb_jobnumbers.add(
              Models.JobNumber.fromJson(jobnumber_array[i]));
          Globals.glb_jobnumbers_with_id[jobnumber_array[i]['id']] =
              Models.JobNumber.fromJson(jobnumber_array[i]);
        }
        return MsgType.SUCCESS;
      }
    } else {
      //throw Exception('Failed to get jobnumbers!');
      return MsgType.FAIL;
    }
  }

  Future<void>getCompanyList() async {
    final response = await http.post(this.baseUrl + '/company-list/get', headers: {
      'X-API-TOKEN': Globals.shared.apiToken
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      List<dynamic> company_list = json["data"]["company_list"];

      Globals.glb_companies.clear();
      for (var i = 0; i < company_list.length; i ++) {
        Globals.glb_companies.add(
            Models.Company.fromJson(company_list[i]));
        Globals.glb_companies_with_id[company_list[i]['id']] = Models.Company.fromJson(company_list[i]);
      }
    } else {
      throw Exception('Failed to get jobnumbers!');
    }
  }

}
