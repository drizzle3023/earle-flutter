class Constants {

  static final Constants shared = Constants();

  Constants() {}

  String appName = "Earle";
  String baseUrl = 'http://18.222.111.142';
  //String baseUrl = 'http://192.168.0.110:8085';

  String baseApiUrl() {
    return this.baseUrl + "/api";
  }

  String baseImageUrl() {
    return this.baseUrl + "/images/";
  }

}
