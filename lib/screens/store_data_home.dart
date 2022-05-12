import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:my_attic/controllers/store_data_home_controller.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDataHome extends StatelessWidget {
  final StoreDataHomeController _controller = Get.find<StoreDataHomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            height: Get.height * 0.85,
            margin: EdgeInsets.only(
              top: Get.height * 0.05,
              left: Get.width * 0.05,
              right: Get.width * 0.05,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_controller.link.value.isEmpty) {
                      return;
                    }
                    Vibrate.feedback(FeedbackType.impact);
                    if (!await launch(_controller.link.value))
                      throw 'Could not launch $_controller.link.value';
                  },
                  child: Container(
                    width: Get.width,
                    height: Get.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Obx(
                      () => (_controller.image.value.isEmpty)
                          ? (_controller.isLoading.value)
                              ? Center(child: CupertinoActivityIndicator())
                              : Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
                                  child: FaIcon(
                                    FontAwesomeIcons.solidImage,
                                    size: Get.height * 0.15,
                                    color: Colors.black12,
                                  ),
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: _controller.image.value,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.075),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Visibility(
                            visible: !_controller.isLoading.value,
                            child: Text(
                              _controller.title.value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: Get.height * 0.04,
                                fontWeight: FontWeight.bold,
                                height: 1,
                                fontFamily: 'Dongle',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: Get.height * 0.01,
                        ),
                        Obx(
                          () => Visibility(
                            visible: !_controller.isLoading.value,
                            child: Text(
                              _controller.linkShortCut.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Get.height * 0.02,
                                height: 1,
                                color: Colors.green.shade300,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Dongle',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: Get.height * 0.02,
                        ),
                        Obx(
                          () => Visibility(
                            visible: !_controller.isLoading.value,
                            child: Text(
                              _controller.description.value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Get.height * 0.025,
                                height: 1,
                                color: Colors.black26,
                                fontFamily: 'Dongle',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: Get.height * 0.02,
                        ),
                        Text(
                          'Keywords',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Get.height * 0.03,
                            height: 1,
                            color: Colors.red.shade300,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Dongle',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: Get.height * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Vibrate.feedback(FeedbackType.impact);
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      }
                    },
                    child: Container(
                      width: Get.height * 0.08,
                      height: Get.height * 0.08,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.xmark,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      shape: CircleBorder(),
                      primary: Colors.orange.shade300,
                      onPrimary: Colors.white,
                      shadowColor: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.005,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Vibrate.feedback(FeedbackType.impact);
                    },
                    child: Container(
                        width: Get.height * 0.1,
                        height: Get.height * 0.1,
                        child: Center(child: FaIcon(FontAwesomeIcons.solidBookmark))),
                    style: ElevatedButton.styleFrom(
                      elevation: 15,
                      shape: CircleBorder(),
                      primary: Colors.pink.shade300,
                      onPrimary: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.005,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_controller.link.value.isEmpty) {
                        return;
                      }
                      Vibrate.feedback(FeedbackType.impact);
                      if (!await launch(_controller.link.value))
                        throw 'Could not launch $_controller.link.value';
                    },
                    child: Container(
                      width: Get.height * 0.08,
                      height: Get.height * 0.08,
                      child: Center(child: FaIcon(FontAwesomeIcons.globe)),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 15,
                      shape: CircleBorder(),
                      primary: Colors.blue.shade300,
                      onPrimary: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
