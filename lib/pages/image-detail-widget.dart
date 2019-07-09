import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

import '../libs/constants.dart';
import '../models/models.dart' as Models;
import 'package:Earle/libs/global.dart';

import '../api-manager.dart';

class ImageDetail extends StatefulWidget {
  final Models.Image image;
  final bool editable;
  final int upload_ts;

  ImageDetail(
      {Key key,
      @required this.image,
      @required this.editable,
      @required this.upload_ts})
      : super(key: key);

  @override
  ImageDetailState createState() => ImageDetailState();
}

class ImageDetailState extends State<ImageDetail> {
  //image base url
  String imgbaseUrl = Constants.shared.baseImageUrl() +
      "original/"; // 'http://18.222.111.142/images/';
  DateTime _date;
  bool _isSaving = false;

  var txtLatCtl = new TextEditingController();
  var txtLngCtl = new TextEditingController();
  var txtTitleCtl = new TextEditingController();
  var txtRouteCtl = new TextEditingController();
  var txtAssetCtl = new TextEditingController();
  var txtCommentCtl = new TextEditingController();
  var txtUrgencyCtl = new TextEditingController();

  List<Models.JobNumber> jobNoList = [];

  Models.JobNumber selectedJobNumber;

  @override
  void initState() {
    super.initState();

    _date = DateTime.fromMillisecondsSinceEpoch(widget.upload_ts * 1000);
    txtLatCtl.text = widget.image.latitude.toString();
    txtLngCtl.text = widget.image.longitude.toString();
    txtTitleCtl.text =
        widget.image.title != null ? widget.image.title.toString() : '';
    txtRouteCtl.text =
        widget.image.route != null ? widget.image.route.toString() : '';
    txtAssetCtl.text =
        widget.image.asset != null ? widget.image.asset.toString() : '';
    txtCommentCtl.text =
        widget.image.comment != null ? widget.image.comment.toString() : '';
    txtUrgencyCtl.text =
        widget.image.urgency != null ? widget.image.urgency.toString() : '';

    for (var i = 0; i < Globals.glb_jobnumbers.length; i++) {
      jobNoList.add(Globals.glb_jobnumbers[i]);
      if (Globals.glb_jobnumbers[i].id == widget.image.jobnumber_id) {
        selectedJobNumber = Globals.glb_jobnumbers[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Image Detail"),
        ),
        body: Column(children: <Widget>[
          Opacity(
            opacity: _isSaving ? 1 : 0,
            child: LinearProgressIndicator(),
          ),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Form(
                      child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: <Widget>[
                        InkWell(
                          child: Container(
                            child: SizedBox(
                              height: 200,
                              child: new ClipRRect(
                                borderRadius: new BorderRadius.circular(3.0),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Center(child: new Icon(Icons.error)),
                                  imageUrl:
                                      this.imgbaseUrl + widget.image.filename,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              //                          FadeInImage.memoryNetwork(
                              //                            placeholder: kTransparentImage,
                              //                            image: this.imgbaseUrl + image.name,
                              //                            fit: BoxFit.cover,
                              //                          ),
                            ),
                          ),
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(labelText: 'Creator'),
                          initialValue: widget.image.user.name.toString(),
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Latitude'),
                          controller: txtLatCtl,
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Longitude'),
                          controller: txtLngCtl,
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Title'),
                          controller: txtTitleCtl,
                        ),
                        Visibility(
                          visible: !widget.editable,
                          child: TextFormField(
                            enabled: widget.editable,
                            decoration: InputDecoration(labelText: 'JobNumber'),
                            initialValue: Globals
                                .glb_jobnumbers_with_id[
                                    widget.image.jobnumber_id]
                                .jobnumber
                                .toString(),
                          ),
                        ),
                        Visibility(
                          visible: widget.editable,
                          child: new FormField(
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
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Route'),
                          controller: txtRouteCtl,
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Asset'),
                          controller: txtAssetCtl,
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Comment'),
                          controller: txtCommentCtl,
                        ),
                        TextFormField(
                          enabled: widget.editable,
                          decoration: InputDecoration(labelText: 'Urgency'),
                          controller: txtUrgencyCtl,
                        ),
                        DateTimePickerFormField(
                          inputType: InputType.both,
                          format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                          editable: widget.editable,
                          decoration: InputDecoration(
                              labelText: 'Date/Time',
                              hasFloatingPlaceholder: true),
                          initialValue: _date,
                          onChanged: (dt) => setState(() => _date = dt),
                        ),
                        Visibility(
                          visible: widget.editable,
                          child: new Container(
                              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                              child: _isSaving == false
                                  ? new RaisedButton(
                                      child: const Text('Save'),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      highlightElevation: 3.0,
                                      onPressed: _save,
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    )),
                        ),
                      ]))))
        ]));
  }

  void _save() {
    if (txtLngCtl.text.isEmpty || txtLatCtl.text.isEmpty) {
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
        _isSaving = true;
      });

      ApiManager.shared
          .updateImage(
              lat: txtLatCtl.text,
              lng: txtLngCtl.text,
              title: txtTitleCtl.text,
              jobNo_id: selectedJobNumber.id,
              route: txtRouteCtl.text,
              asset: txtAssetCtl.text,
              comment: txtCommentCtl.text,
              urgency: txtUrgencyCtl.text,
              upload_timestamp: (_date.millisecondsSinceEpoch / 1000).round(),
              image_id: widget.image.id)
          .then((data) {
        setState(() {
          _isSaving = false;
        });

        if (data == MsgType.SUCCESS) {
          Globals.shared.showToast(context, "Update succeed",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          //loadMore();
        } else {
          Globals.shared.showToast(context, "Update image failed",
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      });
    }
  }
}
