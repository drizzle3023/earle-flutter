import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:location/location.dart';
import 'package:toast/toast.dart';
import 'package:exif/exif.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:dotted_border/dotted_border.dart';

import '../api-manager.dart';
import '../libs/constants.dart';
import '../models/models.dart' as Models;
import 'package:Earle/libs/global.dart';

class ImageUpload extends StatefulWidget {
  ImageUpload({Key key}) : super(key: key);

  @override
  ImageUploadState createState() => ImageUploadState();
}

class ImageUploadState extends State<ImageUpload> {
  //image base url
  String imgbaseUrl =
      Constants.shared.baseImageUrl(); // 'http://18.222.111.142/images/';
  bool _isUploading = false;
  bool _isGPSbased = null;              // get image location data from current location

  File _selectedImage4Upload;

  var txtLatCtl = new TextEditingController();
  var txtLngCtl = new TextEditingController();
  var txtTitleCtl = new TextEditingController();
  var txtRouteCtl = new TextEditingController();
  var txtAssetCtl = new TextEditingController();
  var txtCommentCtl = new TextEditingController();
  var txtUrgencyCtl = new TextEditingController();

  List<Models.JobNumber> jobNoList = [];

  Models.JobNumber selectedJobNumber;

  DateTime _date; // Used for upload

  Location location = Location();
  @override
  void initState() {
    super.initState();

    jobNoList.add(new Models.JobNumber(
        id: 0, jobnumber: "Please select..", company_id: 0));
    for (var i = 0; i < Globals.glb_jobnumbers.length; i++) {
      jobNoList.add(Globals.glb_jobnumbers[i]);
    }

    selectedJobNumber = jobNoList[0];
    _date = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Image Upload"),
        ),
        body: Column(
          children: <Widget>[
            Opacity(
              opacity: _isUploading ? 1 : 0,
              child: LinearProgressIndicator(),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Form(
                    //key: _formKey,
                    //autovalidate: true,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: <Widget>[
                        InkWell(
                          onTap: _optionsDialogBox,
                          child: DottedBorder(
                            color: Colors.grey[800],
                            gap: 5,
                            strokeWidth: 2,
                            child: Container(
//                              decoration: BoxDecoration(
//                                border: Border.all(
//                                    color: Colors.grey,
//                                    width: 2.0,
//                                    style: BorderStyle.solid
//                                ),
//                              ),
                              child: SizedBox(
                                height: 200,
                                child: _selectedImage4Upload == null
                                    ? Center(child: Text('Tap to add image'))
                                    : Center(
                                        child: Widgets.Image.file(
                                        _selectedImage4Upload,
                                        fit: BoxFit.cover,
                                      )),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            new Expanded(
                                child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Latitude', labelText: 'Latitude'),
                              controller: txtLatCtl,
                            )),
                            new SizedBox(
                              width: 5,
                            )
                            ,
                            new Expanded(
                              child: TextFormField(
                                controller: txtLngCtl,
                                decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                    hintText: 'Longitude'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.image),
                              onPressed: _onGetFromImageButtonPressed,
                              color: this._isGPSbased == true || this._isGPSbased == null ? null : Theme.of(context).primaryColor,
                            ),
                            IconButton(
                              icon: Icon(Icons.gps_fixed),
                              onPressed: _onGetFromGPSButtonPressed,
                              color: this._isGPSbased == false || this._isGPSbased == null ? null : Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                        TextFormField(
                          controller: txtTitleCtl,
                          decoration: const InputDecoration(
                              labelText: 'Title', hintText: 'Title'),
                        ),
                        new FormField(
                          builder: (FormFieldState state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'JobNumber',
                              ),
                              isEmpty: selectedJobNumber == null,
                              child: new DropdownButtonHideUnderline(
                                child: DropdownButton<Models.JobNumber>(
                                  value: selectedJobNumber,
                                  isDense: true,
                                  onChanged: (Models.JobNumber newValue) {
                                    setState(() {
                                      selectedJobNumber = newValue;
                                    });
                                  },
                                  items: jobNoList
                                      .map((Models.JobNumber jobnumber) {
                                    return DropdownMenuItem<Models.JobNumber>(
                                      value: jobnumber,
                                      child: Text(jobnumber.jobnumber),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        new TextFormField(
                          controller: txtRouteCtl,
                          decoration: const InputDecoration(
                            hintText: 'Route',
                            labelText: 'Route',
                          ),
                        ),
                        new TextFormField(
                          controller: txtAssetCtl,
                          decoration: const InputDecoration(
                            hintText: 'Asset',
                            labelText: 'Asset',
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            //WhitelistingTextInputFormatter.digitsOnly,
                          ],
                        ),
                        new TextFormField(
                          controller: txtCommentCtl,
                          decoration: const InputDecoration(
                            hintText: 'Comment',
                            labelText: 'Comment',
                          ),
                          //keyboardType: TextInputType.emailAddress,
                        ),
                        new TextFormField(
                          controller: txtUrgencyCtl,
                          decoration: const InputDecoration(
                            hintText: 'Urgency',
                            labelText: 'Urgency',
                          ),
                          //keyboardType: TextInputType.emailAddress,
                        ),
                        DateTimePickerFormField(
                          inputType: InputType.both,
                          format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                          editable: true,
                          decoration: InputDecoration(
                              labelText: 'Date/Time',
                              hasFloatingPlaceholder: true),
                          initialValue: _date,
                          onChanged: (dt) => setState(() => _date = dt),
                        ),
                        new Container(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: _isUploading == false
                                ? new RaisedButton(
                                    child: const Text('UPLOAD'),
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    highlightElevation: 3.0,
                                    onPressed: _upload,
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  )),
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }

  Future<void> _optionsDialogBox() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Take a picture'),
                    onTap: _openCamera,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text('Select from gallery'),
                    onTap: _openGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  _openCamera() async {
    Navigator.pop(context);

    var picture = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    print(picture);
    setState(() {
      this._selectedImage4Upload = picture;
      if (this._isGPSbased == false) {
        _onGetFromImageButtonPressed();
      }
    });
  }

  _openGallery() async {
    Navigator.pop(context);
    var gallery = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    print(gallery);

    setState(() {
      this._selectedImage4Upload = gallery;
      if (this._isGPSbased == false) {
        _onGetFromImageButtonPressed();
      }
    });
  }

  _onGetFromImageButtonPressed() async{

    if (_selectedImage4Upload != null) {
      Globals.shared.showToast(context, "Getting location from image",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      readExifFromBytes(
          await new File(_selectedImage4Upload.path).readAsBytes()).then((
          Map<String, IfdTag> data) {

        if (data == null || data.isEmpty) {
          Globals.shared.showToast(context, "No EXIF information found",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          setState(() {
            this._isGPSbased = false;
            txtLatCtl.text = "";
            txtLngCtl.text = "";
          });

        } else if (data.containsKey("GPS GPSLatitude") && data.containsKey("GPS GPSLongitude")) {
          var lat1 = double.parse(data["GPS GPSLatitude"].values[0].toString());
          var lat2 = double.parse(data["GPS GPSLatitude"].values[1].toString()) / 60;
          var latsec1 = double.parse(data["GPS GPSLatitude"].values[2].toString().split('/')[0]);
          var latsec2 = double.parse(data["GPS GPSLatitude"].values[2].toString().split('/')[1]);
          var lat3 = latsec1 / latsec2 / 3600;

          var lng1 = double.parse(data["GPS GPSLongitude"].values[0].toString());
          var lng2 = double.parse(data["GPS GPSLongitude"].values[1].toString()) / 60;
          var lngsec1 = double.parse(data["GPS GPSLongitude"].values[2].toString().split('/')[0]);
          var lngsec2 = double.parse(data["GPS GPSLongitude"].values[2].toString().split('/')[1]);
          var lng3 = lngsec1 / lngsec2 / 3600;

          print(data["GPS GPSLatitude"].values[0]);
          print(data["GPS GPSLatitude"].values[1]);
          print(data["GPS GPSLatitude"].values[2]);
          print(data["GPS GPSLongitude"].values[0]);
          print(data["GPS GPSLongitude"].values[1]);
          print(data["GPS GPSLongitude"].values[2]);

          var latitude = lat1 + lat2 + lat3;
          var longitude = lng1 + lng2 + lng3;
          print(latitude);
          print(longitude);

          setState(() {
            this._isGPSbased = false;
            txtLatCtl.text = latitude.toStringAsFixed(7);
            txtLngCtl.text = longitude.toStringAsFixed(7);
          });

        } else {
          Globals.shared.showToast(context, "There is no GPS information in this image",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          setState(() {
            this._isGPSbased = false;
            txtLatCtl.text = "";
            txtLngCtl.text = "";
          });
        }

      });

    } else {
      Globals.shared.showToast(context, "Please select image first",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  _onGetFromGPSButtonPressed() async {
    setState(() {
      this._isGPSbased = true;
      location.getLocation().then((currentLocation) {
        txtLatCtl.text = currentLocation.latitude.toString();
        txtLngCtl.text = currentLocation.longitude.toString();
      });
      Globals.shared.showToast(context, "Getting location from GPS",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  void _upload() {
    if (_selectedImage4Upload == null) {
      Globals.shared.showToast(context, "Please select the image",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (txtLngCtl.text.isEmpty || txtLatCtl.text.isEmpty) {
      Globals.shared.showToast(context, "Please input Latitude and Longitude",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (selectedJobNumber == null || selectedJobNumber.id == 0) {
      Globals.shared.showToast(context, "Please select Job Number",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_date == null) {
      Globals.shared.showToast(context, "Please input date",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() {
        _isUploading = true;
      });

      ApiManager.shared
          .doUpload(
              file: _selectedImage4Upload,
              lat: txtLatCtl.text,
              lng: txtLngCtl.text,
              title: txtTitleCtl.text,
              jobNo_id: selectedJobNumber.id,
              route: txtRouteCtl.text,
              asset: txtAssetCtl.text,
              comment: txtCommentCtl.text,
              urgency: txtUrgencyCtl.text,
              upload_timestamp: (_date.millisecondsSinceEpoch / 1000).round())
          .then((data) {
        setState(() {
          _isUploading = false;
        });

        if (data == MsgType.SUCCESS) {
          Globals.shared.showToast(context, "Upload succeed",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          setState(() {
            _selectedImage4Upload = null;
            txtTitleCtl.text = "";
            txtRouteCtl.text = "";
            txtAssetCtl.text = "";
            txtCommentCtl.text = "";
            txtUrgencyCtl.text = "";
            selectedJobNumber = jobNoList[0];
            _date = DateTime.now();
            _isGPSbased = null;
            txtLatCtl.text = "";
            txtLngCtl.text = "";
          });
          //loadMore();
        } else {
          Globals.shared.showToast(context, "Upload failed",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      });
    }
  }
}
