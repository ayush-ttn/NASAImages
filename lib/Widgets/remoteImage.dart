
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RemoteImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  RemoteImage({@required this.url, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (ctx, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: this.fit,
            ),
          ),
        );
      },
    );
  }
}
