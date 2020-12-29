import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:Images/models.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<ImageModel>> getImagesFromServer() async {
  try {
    final response = await http.get(
        "https://api.factmaven.com/xml-to-json/?xml=https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss");
    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body) as Map<String, dynamic>;
      final rss = json["rss"] as Map<String, dynamic>;
      final channel = rss["channel"] as Map<String, dynamic>;
      final items = channel["item"] as List<dynamic>;
      final List<ImageModel> images = [];
      items.forEach((element) {
        final title = element["title"] as String;
        final description = element["description"] as String;
        final link = element["link"] as String;
        final url = element["enclosure"]["@url"] as String;
        final dateStr = element["pubDate"] as String;
        print("date is $dateStr");
        //Mon, 28 Dec 2020 02:46 EST
        final date = DateFormat("EEE, dd MMM yyyy HH:mm z").parse(dateStr);
        print("parsed date ${date.timeZoneName}");
        final utc = date.toUtc();
        final local = utc.toLocal();
        print("utc = $utc local= $local");
        images.add(ImageModel(
            title: title,
            description: description,
            url: url,
            detailsUrl: link,
            date: date));
      });
      return images;
    } else {
      return [];
    }
  } catch (error) {
    throw error;
  }
}

Future<Uint8List> getImageData(String url) async {
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = response.bodyBytes;
      return data;
    } else {
      throw "Image downlaoad failed";
    }
  } catch (exection) {
    throw exection;
  }
}
