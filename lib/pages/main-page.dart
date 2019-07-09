import 'dart:async';
import 'dart:io';

import 'package:Earle/pages/search-page.dart';
import 'package:Earle/reusable-widget/loading-indicator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import '../models/models.dart' as Models;
import '../api-manager.dart';
import '../libs/constants.dart';
import '../libs/global.dart';
import 'package:Earle/libs/shared-preferences-helper.dart';
import 'image-detail-widget.dart';
import 'image-list-page.dart';
import 'map-page.dart';
import 'image-upload-widget.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _previousPosition = 0;
  int _currentPosition = 0;

  int _shownCount = 0;
  int _totalCount = 0;

//  Map<String, Object> _imageListClause = {};
  List<Models.Image> _images = [];
  Map<MarkerId, Marker> _markers = {};

  final GlobalKey bottomNavigationKey = GlobalKey();

  LatLng _cameraPosition = LatLng(0.0, 0.0);

  bool _isSearching = false;
  bool _isCenterMap = false;
  String _appBarTitle = Constants.shared.appName;
  Map<String, Object> _searchClause = {};

  @override
  void initState() {
    super.initState();

    // _showSearchDialog();
    Future.delayed(Duration.zero, () => _showSearchDialog());
  }

  void _updateImageList(
      List<Models.Image> imgList, int shownCount, int totalCount) {
    setState(() {
      this._images.clear();
      this._images.addAll(imgList);
      this._shownCount = shownCount;
      this._totalCount = totalCount;
//
//      this._imageListClause["images"] = this._images;
//      this._imageListClause["images"] = this._images;
//
      showMarkers(this._images);
      if (imgList.length > 0) {
        this._cameraPosition =
            LatLng(imgList[0].latitude, imgList[0].longitude);
        this._isCenterMap = true;
      }
    });
  }

  void _getSearchResult(List<Models.Image> imageList, int totalCount,
      Map<String, Object> searchClause) {
    setState(() {
      this._isSearching = true;
      this._appBarTitle = "Search Result";
      this._images.clear();
      this._images.addAll(imageList);
      this._shownCount = imageList.length;
      this._totalCount = totalCount;
      this._searchClause = searchClause;
      showMarkers(this._images);
      if (imageList.length > 0) {
        this._cameraPosition =
            LatLng(imageList[0].latitude, imageList[0].longitude);
        this._isCenterMap = true;
      }
      final FancyBottomNavigationState fState =
          bottomNavigationKey.currentState;
      fState.setPage(0);
    });
  }

  void _onCenterMapChanged() {
    setState(() {
      this._isCenterMap = false;
    });
  }

  void _onClearButtonClicked() {
    setState(() {
      this._appBarTitle = Constants.shared.appName;
      this._isSearching = false;
      this._searchClause = {};
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Do you want to exit?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () => exit(0),
                    child: new Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
        fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold);



    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Search',
                onPressed: _onSearchButtonPressed,
              ),
              IconButton(
                icon: Icon(Icons.file_upload),
                tooltip: 'Upload',
                onPressed: _onUploadButtonPressed,
              )
            ],
          ),
          body: IndexedStack(
            index: _currentPosition,
            children: <Widget>[
              ImageListPage(
                images: this._images,
                shownCount: this._shownCount,
                totalCount: this._totalCount,
                onChanged: this._updateImageList,
                isSearching: this._isSearching,
                searchClause: this._searchClause,
                onClearButtonClicked: this._onClearButtonClicked,
              ),
              MapPage(
                markers: this._markers,
                cameraPosition: this._cameraPosition,
                isCenterMap: this._isCenterMap,
                onChanged: this._onCenterMapChanged,
              )
            ],
          ),
          drawer: Drawer(
              child: ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountName: new Text(Globals.shared.userName),
                accountEmail: new Text(Globals.shared.userEmail),
                currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.white,
                  child: new Text(Globals.shared.userName.substring(0, 1)),
                ),
              ),
              new ListTile(
                title: new Text("Logout", style: style),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text('Are you sure?'),
                          content: new Text('Do you want to log out?'),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: new Text('No'),
                            ),
                            new FlatButton(
                              onPressed: () {
                                SharedPreferencesHelper.clearStoredData();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (Route<dynamic> route) => false);
                              },
                              child: new Text('Yes'),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          )),
          bottomNavigationBar: FancyBottomNavigation(
            key: bottomNavigationKey,
            tabs: [
              TabData(
                  iconData: Icons.photo_library,
                  title: "Images",
                  onclick: () {
                    final FancyBottomNavigationState fState =
                        bottomNavigationKey.currentState;
                    fState.setPage(0);
                  }),
              TabData(
                  iconData: Icons.map,
                  title: "Map",
                  onclick: () {
                    final FancyBottomNavigationState fState =
                        bottomNavigationKey.currentState;
                    fState.setPage(1);
                  }),
            ],
            initialSelection: 0,
            onTabChangedListener: (position) {
              setState(() {
                _currentPosition = position;
                _previousPosition = position;
                if (_currentPosition == 1 || !_isSearching) {
                  this._appBarTitle = Constants.shared.appName;
                } else {
                  this._appBarTitle = "Search Result";
                }
              });
            },
          ),
        ));
  }

  Future<Widget> _onSearchButtonPressed() {
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => LoadingIndicator()),
//    );
    return showDialog(
        context: context,
        builder: (_) => SearchPage(
              getSearchResult: _getSearchResult,
            ));
//    return showDialog(
//      context: context,
//      barrierDismissible: false,
//      child: new Dialog(
//        child: SpinKitRotatingCircle(
//          color: Colors.white,
//          size: 50.0,
//        )
//      ),
//    );
  }

  void _onUploadButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageUpload()),
    );
    setState(() {
      final FancyBottomNavigationState fState =
          bottomNavigationKey.currentState;
      fState.setPage(_previousPosition);
    });
  }

  _showSearchDialog() async {
    showDialog(
        context: context,
        builder: (_) => SearchPage(
          getSearchResult: _getSearchResult,
        ));
  }

  showMarkers(List<Models.Image> images) {
    images.forEach((image) {
      //if (!_markers.containsKey(MarkerId(image.id.toString()))) {
      final String markerIdVal = image.id.toString();
      final MarkerId markerId = MarkerId(markerIdVal);

      DefaultCacheManager()
          .getSingleFile(
              Constants.shared.baseImageUrl() + "marker/" + image.filename)
          .then((file) {
        var bytes = file.readAsBytesSync();

        final Marker marker = Marker(
            markerId: markerId,
            icon: BitmapDescriptor.fromBytes(bytes),
            position: LatLng(
              image.latitude,
              image.longitude,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageDetail(
                          image: image,
                          editable: image.user.id == Globals.shared.userId ||
                              Globals.shared.userRole == UserRole.SUPER,
                          upload_ts: image.upload_ts,
                        )),
              );
            });

        setState(() {
          // adding a new marker to map
          _markers[markerId] = marker;
          //_markerExistflag[markerId] = 1;
        });
      });
      //}
    });
  }
}
