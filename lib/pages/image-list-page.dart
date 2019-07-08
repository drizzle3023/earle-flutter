import 'package:Earle/libs/shared-preferences-helper.dart';
import 'package:Earle/pages/search-result-widget.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../api-manager.dart';
import '../libs/constants.dart';
import '../models/models.dart' as Models;
import 'image-detail-widget.dart';
import 'package:Earle/libs/global.dart';

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}

class ImageListPage extends StatefulWidget {
  final List<Models.Image> images;
  final int totalCount;
  final int shownCount;
  final Function(List<Models.Image>, int, int) onChanged;
  final Function() onClearButtonClicked;
  bool isSearching;
  Map<String, Object> searchClause;

  ImageListPage(
      {Key key,
      @required this.images,
      @required this.shownCount,
      @required this.totalCount,
      @required this.onChanged,
      @required this.isSearching,
      @required this.onClearButtonClicked,
      @required this.searchClause})
      : super(key: key);

  @override
  ImageListPageState createState() => ImageListPageState();
}

class ImageListPageState extends State<ImageListPage> {
  //image base url
  String imgbaseUrl = Constants.shared.baseImageUrl() +
      "thumbnail/"; // 'http://18.222.111.142/images/';
  bool _isLoading = false;

  int _shownCount = 0;
  int _totalCount = 0;
  List<Models.Image> _images = [];

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // scrollController.addListener(() {
    //   if (scrollController.position.maxScrollExtent ==
    //           scrollController.offset &&
    //       this._shownCount < this._totalCount) {
    //     loadMore();
    //   }
    // });

    if (widget.images.length == 0) {
      this._refresh();
    }

  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
              scrollController.offset &&
          widget.shownCount < widget.totalCount) {
        loadMore();
      }
    });

    return Scaffold(
        floatingActionButton: new Visibility(
          visible: widget.isSearching,
          child: FloatingActionButton(
            onPressed: _onClearButtonPressed,
            child: Icon(Icons.clear),
          ),
        ),
        body: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Opacity(
                opacity: _isLoading ? 1 : 0,
                child: LinearProgressIndicator(),
              ),
              Expanded(
                  child: RefreshIndicator(
                child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: EdgeInsets.all(10),
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    children: List.generate(widget.images.length, (index) {
                      var image = widget.images[index];

                      return new GridTile(
                        child: new Card(
                            margin: EdgeInsets.all(0.0),
                            elevation: 3.0,
                            child: new InkWell(
                              child:
//                          CachedNetworkImage(
//                            placeholder: (context, url) => CircularProgressIndicator(),
//                            imageUrl: this.imgbaseUrl + image.filename,
//                            fit: BoxFit.cover,
//                          ),
//
                              new ClipRRect(
                                borderRadius: new BorderRadius.circular(3.0),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: this.imgbaseUrl + image.filename,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // enableFeedback: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageDetail(
                                            image: image,
                                            editable: image.user.id ==
                                                    Globals.shared.userId ||
                                                Globals.shared.userRole ==
                                                    UserRole.SUPER,
                                            upload_ts: image.upload_ts,
                                          )),
                                );
                              },
                            )),
                        footer: new ClipRRect(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3.0), bottomRight: Radius.circular(3.0)),
                      child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImageDetail(
                                          image: image,
                                          editable: image.user.id ==
                                                  Globals.shared.userId ||
                                              Globals.shared.userRole ==
                                                  UserRole.SUPER,
                                          upload_ts: image.upload_ts,
                                        )),
                              );
                            },
                            child: GridTileBar(
                              backgroundColor: Colors.black45,
                              title: _GridTitleText(image.description != null
                                  ? image.description
                                  : " "),
                              subtitle: _GridTitleText(
                                  image.latitude.toString() +
                                      ',' +
                                      image.longitude.toString()),
                              trailing: image.user.id ==
                                          Globals.shared.userId ||
                                      Globals.shared.userRole == UserRole.SUPER
                                  ? Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    )
                                  : null,
                            ))),
                      );
                    })),
                onRefresh: _refresh,
              ))
            ],
          )),
        ));
  }

  Future<void> _refresh() {
    _shownCount = 0;

//    if (this._center.latitude == 0 && this._center.longitude == 0) {
//      setState(() {
//        _center = LatLng(this._images[0].latitude.toDouble(), this._images[0].longitude.toDouble());
//      });
//    }

    setState(() {
      _isLoading = true;
    });

    return ApiManager.shared.doSearch(widget.searchClause, 0).then((data) {
      setState(() {
        this._isLoading = false;
      });

      if (data["message"] == MsgType.SUCCESS) {
        setState(() {
          this._images.clear();
          this._images.addAll(data["images"]);
//          widget.images.clear();
//          widget.images.addAll(data["images"]);
          this._shownCount += data['images'].length;
          this._totalCount = data['total'];
//
//          widget.shownCount += data['images'].length;
//          widget.totalCount = data['total'];

          widget.onChanged(this._images, this._shownCount, this._totalCount);
        });
      } else {
        if (data["message"] == MsgType.TOKEN_EXPIRED) {
          SharedPreferencesHelper.clearStoredData();
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
      }
    });
  }

  loadMore() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);

      ApiManager.shared
          .doSearch(widget.searchClause, this._shownCount)
          .then((data) {
        setState(() {
          this._isLoading = false;
        });
        if (data["message"] == MsgType.SUCCESS) {
          setState(() {
            this._images.addAll(data["images"]);
            //widget.images.addAll(data["images"]);
            //this._images = widget.images;
            this._shownCount += data["images"].length;

            //widget.shownCount += data['images'].length;

            widget.onChanged(this._images, this._shownCount, this._totalCount);
          });
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

  void _onClearButtonPressed() {
    widget.onClearButtonClicked();
    widget.isSearching = false;
    widget.searchClause = {};
    this._refresh();
  }
}
