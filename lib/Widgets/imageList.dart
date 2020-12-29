import 'package:Images/Widgets/imageDetail.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'package:flutter/material.dart';
import '../networkHandler.dart' as Network;
import 'remoteImage.dart';

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  List<ImageModel> images = [];
  @override
  void initState() {
    getImages();
    super.initState();
  }

  Future<void> getImages() async {
    try {
      var value = await Network.getImagesFromServer();
      setState(() {
        this.images = value;
        //print(images);
      });
    } catch (error) {
      print("error occured: $error");
    }
  }

  void listTapped(int index, BuildContext context) {
    Navigator.of(context)
        .pushNamed(ImageDetail.routeName, arguments: images[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Image of the day"),
      ),
      body: RefreshIndicator(
        onRefresh: getImages,
        child: ListView.builder(
          itemCount: images.length,
          itemBuilder: (ctx, index) {
            return InkWell(
              child: ImageCell(
                imageModel: images[index],
              ),
              onTap: () {
                this.listTapped(index, ctx);
              },
            );
          },
        ),
      ),
    );
  }
}

class ImageCell extends StatelessWidget {
  final ImageModel imageModel;
  ImageCell({@required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.bottomLeft,
        fit: StackFit.passthrough,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: RemoteImage(url: imageModel.url),
          ),
          ImageTextOverlay(
            title: imageModel.title,
            description: imageModel.description,
            date: DateFormat('dd/MM/yyyy').format(imageModel.date),
          ),
        ],
      ),
    );
  }
}

class ImageTextOverlay extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final bool expanded;
  ImageTextOverlay(
      {@required this.title,
      @required this.description,
      @required this.date,
      this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.black54,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 14,
                )),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.left,
              maxLines: this.expanded ? null : 1,
              overflow: this.expanded ? null : TextOverflow.ellipsis,
            ),
            if (this.expanded)
              Padding(
                padding: EdgeInsets.all(5),
              ),
            Text(
              description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: this.expanded ? null : 2,
              overflow: this.expanded ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
