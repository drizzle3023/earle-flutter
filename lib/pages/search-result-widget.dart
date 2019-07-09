import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class SearchResult extends StatefulWidget {

  final List<Models.Image> images;
  SearchResult({Key key, @required this.images}) : super(key: key);

  @override
  SearchResultState createState() => SearchResultState();
}

class SearchResultState extends State<SearchResult> {


  bool _isLoading = false;

  final scrollController = ScrollController();
  //image base url
  String imgbaseUrl = Constants.shared.baseImageUrl(); // 'http://18.222.111.142/images/';

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Result"),
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
                    child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: EdgeInsets.all(10),
                        controller: scrollController,
                        children: List.generate(widget.images.length, (index) {
                          var image = widget.images[index];

                          return GridTile(
                            child: new InkResponse(
                              child:
//                              CachingImageView(url: this.imgbaseUrl + image.filename),
                                CachedNetworkImage(
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  imageUrl: this.imgbaseUrl + image.filename,
                                  fit: BoxFit.cover,
                                ),
//                              FadeInImage.memoryNetwork(
//                                placeholder: kTransparentImage,
//                                image: this.imgbaseUrl + image.name,
//                                fit: BoxFit.cover,
//                              ),
                              enableFeedback: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ImageDetail(image: image, editable: image.user.id == Globals.shared.userId, upload_ts: image.upload_ts,)),
                                );
                              },
                            ),

                            footer: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ImageDetail(image: image,editable: image.user.id == Globals.shared.userId, upload_ts: image.upload_ts,)),
                                );
                              },
                              child: GridTileBar(
                                backgroundColor: Colors.black45,
                                title: _GridTitleText( image.title != null ? image.title : " "),
                                subtitle: _GridTitleText( image.latitude.toString() + ',' + image.longitude.toString()),
                                trailing: image.user.id == Globals.shared.userId ?
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ) : null,
                              ),
                            ),
                          );
                        })),
                    )
              ],
            )),
      )
    );
  }



}
