class JobNumber {
  int id;
  String jobnumber;
  int company_id;

  JobNumber({this.id, this.jobnumber, this.company_id});

  factory JobNumber.fromJson(Map<String, dynamic> json) {
    return JobNumber(
        id: json['id'],
        jobnumber: json['jobnumber'],
        company_id: json['company_id'],
    );
  }
}
