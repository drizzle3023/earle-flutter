class Company {
  int id;
  String name;

  Company({this.id, this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
        id: json['id'],
        name: json['name']
    );
  }
}
