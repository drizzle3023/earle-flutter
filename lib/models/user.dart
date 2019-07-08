import 'company.dart';

class User {
  int id;
  String name;
  String email;
  Company company;


  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name']
    );
  }
}
