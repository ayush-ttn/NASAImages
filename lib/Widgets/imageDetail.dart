import 'package:Images/Widgets/imageList.dart';
import 'package:Images/Widgets/remoteImage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../networkHandler.dart' as Network;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ImageDetail extends StatefulWidget {
  static String routeName = "ImageDetail";
  ImageModel imageModel;
  ImageDetail({@required this.imageModel});

  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  Widget get _zoomableImage {
    return _ZoomableDetailImage(
      url: widget.imageModel.url,
      panStarted: onImageZoom,
    );
  }

  static const imageSavePlatformMethod =
      const MethodChannel("ayush.app.nasaImages/image");

  var downloadingImage = false;
  var _showText = true;
  void toggleTextVisible() {
    setState(() {
      _showText = !_showText;
    });
  }

  onImageZoom() {
    setState(() {
      _showText = false;
    });
  }

  downloadImage(BuildContext context) async {
    setState(() {
      downloadingImage = true;
    });
    final imageData = await Network.getImageData(widget.imageModel.url);
    try {
      final bool saved =
          await imageSavePlatformMethod.invokeMethod("saveImage", [imageData]);
      setState(() {
        downloadingImage = false;
      });
      if (saved) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Image saved on device."),
          ),
        );
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save image."),
          ),
        );
      }
    } catch (execption) {
      print("Image save failed $execption");
      setState(() {
        downloadingImage = false;
      });
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to download image.\n$execption"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageModel model = ModalRoute.of(context).settings.arguments;
    this.widget.imageModel = model;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Builder(builder: (ctx) {
            return IconButton(
              icon: Icon(Icons.cloud_download_rounded),
              onPressed: () => downloadImage(ctx),
            );
          }),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: Stack(
              alignment: Alignment.bottomLeft,
              fit: StackFit.loose,
              children: [
                InkWell(
                  child: _zoomableImage,
                  onTap: () {
                    toggleTextVisible();
                  },
                ),
                // if (showText)
                AnimatedOpacity(
                  opacity: _showText ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  child: _DetailTexts(
                    title: widget.imageModel.title,
                    description: widget.imageModel.description,
                    date:
                        DateFormat('dd/MM/yyyy').format(widget.imageModel.date),
                    url: widget.imageModel.detailsUrl,
                  ),
                ),
              ],
            ),
          ),
          if (downloadingImage)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _ZoomableDetailImage extends StatelessWidget {
  final String url;
  final Function panStarted;
  _ZoomableDetailImage({@required this.url, this.panStarted});
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      onInteractionStart: (value) => panStarted(),
      child: Container(
        height: double.infinity,
        color: Colors.black,
        child: RemoteImage(
          url: url,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _DetailTexts extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String url;
  _DetailTexts({this.title, this.description, this.date, this.url});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ImageTextOverlay(
          title: title,
          description: description,
          date: date,
          expanded: true,
        ),
        _TapableLinkText(
          url: url,
        ),
      ],
    );
  }
}

class _TapableLinkText extends StatefulWidget {
  final String url;
  _TapableLinkText({this.url});

  @override
  __TapableLinkTextState createState() => __TapableLinkTextState();
}

class __TapableLinkTextState extends State<_TapableLinkText> {
  TapGestureRecognizer _tapGesture;
  @override
  void initState() {
    _tapGesture = TapGestureRecognizer();
    _tapGesture.onTap = _handleTap;
    super.initState();
  }

  void _handleTap() {
    launch(widget.url);
  }

  @override
  void dispose() {
    _tapGesture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: SafeArea(
        top: false,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Read more: ",
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: widget.url,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                recognizer: _tapGesture,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
