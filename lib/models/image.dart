import 'user.dart';

class Image {
  int id;
  String filename;
  String title;
  int jobnumber_id;
  double latitude;
  double longitude;
  String route;
  String asset;
  String comment;
  String urgency;
  int upload_ts;

  User user;

  Image({this.id, this.filename, this.jobnumber_id, this.latitude, this.longitude, this.route,
    this.asset, this.comment, this.urgency, this.title, this.upload_ts});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
        id: json['id'],
        filename: json['filename'],
        jobnumber_id: json['jobnumber_id'],
        latitude: double.parse(json['latitude']),
        longitude: double.parse(json['longitude']),
        route: json['route'],
        asset: json['asset'],
        comment: json['comment'],
        urgency: json['urgency'],
        title: json['title'],
        upload_ts: json['upload_timestamp']
    );
  }
}
