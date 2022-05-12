import 'dart:convert';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class StoreDataHomeController extends GetxController {
  var isLoading = false.obs;

  var data = ''.obs;

  var link = ''.obs;
  var linkShortCut = ''.obs;
  var title = ''.obs;
  var image = ''.obs;
  var description = ''.obs;

  @override
  void onInit() {
    ever(data, (_) async {
      print('[StoreDataHomeController] data = ${data.value}');
      isLoading.value = true;
      _clearData();
      _extractData(data.value).then((value) => isLoading.value = false);
    });
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _extractData(String data) async {
    if (data.isEmpty) {
      print('[StoreDataHomeController] data is empty');
      return;
    }

    var url = '';
    var values = data.split(RegExp(r'\s'));
    url = values.last;

    link.value = url;
    if (url.split('/').length > 2) {
      linkShortCut.value = url.split('/')[2].trim();
    }

    try {
      var header = {
        'User-Agent': 'Mozilla/5.0' +
            ' (Windows NT 10.0; Win64; x64)' +
            ' AppleWebKit/537.36 (KHTML, like Gecko)' +
            ' Chrome/95.0.4638.69 Safari/537.36',
      };
      http.Response response = await http.get(Uri.parse(url), headers: header);

      if (response.body.isEmpty) {
        title.value = data;
      } else {
        BeautifulSoup soup = BeautifulSoup(utf8.decode(response.bodyBytes));

        Bs4Element? titleElement = soup.find('', selector: 'meta[property="og:title"]');
        if (titleElement != null) {
          title.value = titleElement['content']!;
        } else {
          title.value = data;
        }

        Bs4Element? imageElement = soup.find('', selector: 'meta[property="og:image"]');
        if (imageElement != null) {
          image.value = imageElement['content']!;
        }

        Bs4Element? descriptionElement = soup.find('', selector: 'meta[property="og:description"]');
        if (descriptionElement != null) {
          description.value = descriptionElement['content']!;
        } else {
          description.value = url;
        }
      }
    } catch (e) {
      link.value = url;
      title.value = data;
    }

    print('[StoreDataHomeController] _extractData() ----------------');
    print('[StoreDataHomeController] data = $data');
    print('[StoreDataHomeController] link = ${link.value}');
    print('[StoreDataHomeController] linkShortCut = ${linkShortCut.value}');
    print('[StoreDataHomeController] title = ${title.value}');
    print('[StoreDataHomeController] image = ${image.value}');
    print('[StoreDataHomeController] description = ${description.value}');
    print('[StoreDataHomeController] _extractData() ----------------');
  }

  _clearData() {
    link.value = '';
    linkShortCut.value = '';
    title.value = '';
    image.value = '';
    description.value = '';
  }
}
