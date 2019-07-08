import 'package:Earle/libs/shared-preferences-helper.dart';
import 'package:Earle/pages/search-result-widget.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:toast/toast.dart';

import '../api-manager.dart';
import '../libs/constants.dart';
import '../models/models.dart' as Models;
import 'image-detail-widget.dart';
import 'package:Earle/libs/global.dart';
import '../reusable-widget/loading-indicator.dart';

class SearchPage extends StatefulWidget {
  final Function(List<Models.Image>, int, Map<String, Object>) getSearchResult;

  SearchPage({Key key, @required this.getSearchResult}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  // Search Page
  bool _isSearching = false;

  var searchTitleCtl = new TextEditingController();
  var searchRouteCtl = new TextEditingController();
  var searchDescriptionCtl = new TextEditingController();
  var searchCommentCtl = new TextEditingController();

  DateTime _searchStartDate; // Search Start Date
  DateTime _searchEndDate; // Search End Date

  List<Models.JobNumber> jobNoList = [];
  Models.JobNumber searchJobNumber;

  //image base url
  String imgbaseUrl =
      Constants.shared.baseImageUrl(); // 'http://18.222.111.142/images/';

  @override
  void initState() {
    super.initState();

    jobNoList.add(new Models.JobNumber(
        id: 0, jobnumber: "Please select..", company_id: 0));
    for (var i = 0; i < Globals.glb_jobnumbers.length; i++) {
      jobNoList.add(Globals.glb_jobnumbers[i]);
    }

    searchJobNumber = jobNoList[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        contentPadding:
            EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0, bottom: 15.0),
        title: Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            children: <Widget>[
              Text("Search"),
              Expanded(child: SizedBox()),
              IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.clear),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.grey[600],
                alignment: Alignment.centerRight,
              )
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Divider(
              height: 1.0,
              color: Colors.grey,
            ),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new TextFormField(
                      controller: searchTitleCtl,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        labelText: 'Title',
                      ),
                    ),
                    new FormField(
                      builder: (FormFieldState state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'JobNumber',
                          ),
                          isEmpty: searchJobNumber == null,
                          child: new DropdownButtonHideUnderline(
                            child: DropdownButton<Models.JobNumber>(
                              value: searchJobNumber,
                              isDense: true,
                              onChanged: (Models.JobNumber newValue) {
                                setState(() {
                                  searchJobNumber = newValue;
                                });
                              },
                              items:
                                  jobNoList.map((Models.JobNumber jobnumber) {
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
                      controller: searchRouteCtl,
                      decoration: const InputDecoration(
                        hintText: 'Route',
                        labelText: 'Route',
                      ),
                    ),
                    new TextFormField(
                      controller: searchDescriptionCtl,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    new TextFormField(
                      controller: searchCommentCtl,
                      decoration: const InputDecoration(
                        hintText: 'Comment',
                        labelText: 'Comment',
                      ),
                      //keyboardType: TextInputType.emailAddress,
                    ),
                    DateTimePickerFormField(
                      inputType: InputType.both,
                      format: DateFormat("MMMM d, yyyy 'at' h:mma"),
                      editable: true,
                      decoration: InputDecoration(
                          labelText: 'Start Date',
                          hasFloatingPlaceholder: true),
                      onChanged: (dt) => setState(() => _searchStartDate = dt),
                    ),
                    DateTimePickerFormField(
                      inputType: InputType.both,
                      format: DateFormat("MMMM d, yyyy 'at' h:mma"),
                      editable: true,
                      decoration: InputDecoration(
                          labelText: 'End Date', hasFloatingPlaceholder: true),
                      onChanged: (dt) => setState(() => _searchEndDate = dt),
                    ),
                  ],
                ),
              ),
            ),

//          new Container(
//              padding: const EdgeInsets.only(top: 20.0),
//              child: new RaisedButton(
//                child: const Text('Search'),
//       //         onPressed: _doSearch,
//              )),
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _isSearching == false
                        ? FlatButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            shape: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: Text("Search"),
                            onPressed: _doSearch,
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Future<void> _doSearch() {
    if (searchTitleCtl.text == "" &&
        searchRouteCtl.text == "" &&
        searchDescriptionCtl.text == "" &&
        searchCommentCtl.text == "" &&
        (searchJobNumber == null || searchJobNumber.id == 0) &&
        (_searchStartDate == null ||
            _searchStartDate.millisecondsSinceEpoch == 0) &&
        (_searchEndDate == null ||
            _searchEndDate.millisecondsSinceEpoch == 0)) {
      Globals.shared.showToast(context, "Please fill at least one field",
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {

//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => LoadingIndicator()),
//      );

      setState(() {
        _isSearching = true;
      });

      Map<String, Object> searchClause = {
        "title": searchTitleCtl.text,
        "route": searchRouteCtl.text,
        "description": searchDescriptionCtl.text,
        "comment": searchCommentCtl.text,
        "job_id": searchJobNumber.id,
        "start_date": _searchStartDate == null
            ? 0
            : (_searchStartDate.millisecondsSinceEpoch / 1000).round(),
        "end_date": _searchEndDate == null
            ? 0
            : (_searchEndDate.millisecondsSinceEpoch / 1000).round()
      };

      ApiManager.shared.doSearch(searchClause, 0).then((data) {
        //Navigator.pop(context);

        setState(() {
          _isSearching = false;
        });

        if (data["message"] == MsgType.SUCCESS) {
          if (data["images"].length == 0) {
            Globals.shared.showToast(context, "No Search Result",
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            Navigator.pop(context);
            widget.getSearchResult(data["images"], data["total"], searchClause);
          }
        } else {
          if (data["message"] == MsgType.TOKEN_EXPIRED) {
            SharedPreferencesHelper.clearStoredData();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
          }
        }
      });
    }
  }
}
