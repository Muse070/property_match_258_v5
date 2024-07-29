import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/utils/pick_image.dart';
import 'package:sizer/sizer.dart';

class Uploads extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const Uploads({
    super.key,
    required this.formKey
  });

  @override
  State<Uploads> createState() => _UploadsState();
}

class _UploadsState extends State<Uploads> {
  ListingController _listingController = Get.find<ListingController>();

  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();

  bool imageListIsEmpty = true;
  bool docListIsEmpty = true;

  int? pages;
  bool isReady = false;


  // List<Uint8List>? docFiles = [];
  // List<Map<String, dynamic>> docMapList= [];
  // List<String> docResultList = [];

  @override
  void initState() {
    super.initState();

    if (_listingController.imageListStrDyn.isNotEmpty) {
      imageListIsEmpty = false;
    }

    if (_listingController.docListStrDyn.isNotEmpty
        && _listingController.docPathList.isNotEmpty) {
      setState(() {
        docListIsEmpty = false;
      });
    }
  }

  bool validateSelection() {
    return _listingController.imageListStrDyn.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Images",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        imageListIsEmpty
            ? Card(
          elevation: 2,
          color: Colors.white,
          child: Container(
            alignment: Alignment.center,
            height: 25.h,
            width: 100.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 34.sp,
                    ),
                    Text(
                      "Upload images",
                      style: TextStyle(fontSize: 12.sp),
                    )
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final List<Map<String, dynamic>> result =
                    await pickMultipleImagesAndVideos();
                    print(result);

                    if (result.isNotEmpty) {
                      setState(() {
                        // mediaFiles = mediaMapList.map((fileMap) =>
                        // fileMap['bytes'] as Uint8List).toList();
                        _listingController.imageListStrDyn.addAll(result);


                        // _listingController.updateImageListStrDyn(mediaMapList);
                        imageListIsEmpty = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF005555)),
                      foregroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white)),
                  child: const Text("Upload"),
                ),
                const Spacer()
              ],
            ),
          ),
        )
            : Obx(() {
          return Column(
            children: [
              SizedBox(
                  height: 20.h,
                  width: 100.w,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      // scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 0; i <
                            _listingController.imageListStrDyn.length; i++) ...[
                          Stack(
                            children: [
                              Image.memory(
                                _listingController.imageListStrDyn[i]['bytes'] as Uint8List,
                                width: 18.h,
                                height: 18.h,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0.3.h,
                                left: 1.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    // Choose a color that contrasts with the icon color
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (i < _listingController.imageListStrDyn.length) {
                                            _listingController.imageListStrDyn.removeAt(i);
                                            if (_listingController.imageListStrDyn.isEmpty) {
                                              imageListIsEmpty = true;
                                            }
                                          }
                                        });
                                      },
                                    child: IconTheme(
                                      data: IconThemeData(
                                          size: 18.sp, color: Colors.black),
                                      child: const FaIcon(
                                        FontAwesomeIcons.circleXmark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (i != _listingController.imageListStrDyn.length - 1)
                            SizedBox(
                              width: 2.5.w,
                            )
                        ]
                      ],
                    ),
                  )
              ),
              SizedBox(
                height: 2.h,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: IconTheme(
                      data: IconThemeData(size: 8.sp, color: Colors.white),
                      child: const FaIcon(FontAwesomeIcons.plus),
                    ),
                    label: Text(
                      'Add',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 8.sp),
                    ),
                    onPressed: () async {
                      List<Map<String,
                          dynamic>> result = await pickMultipleImagesAndVideos();

                      if (result.isNotEmpty) {
                        setState(() {
                          _listingController.imageListStrDyn.addAll(result);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 1.h),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF005555),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      minimumSize: Size(5.w, 3.h),
                    ),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  ElevatedButton.icon(
                    icon: IconTheme(
                      data: IconThemeData(size: 8.sp, color: Colors.white),
                      child: const FaIcon(FontAwesomeIcons.trash),
                    ),
                    label: Text(
                      'Delete All',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 8.sp),
                    ),
                    onPressed: () {
                      setState(() {
                        _listingController.imageListStrDyn.clear();
                        imageListIsEmpty = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 1.h),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF005555),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        minimumSize: Size(5.w, 3.h)),
                  ),
                ],
              )
            ],
          );
        }),
        SizedBox(
          height: 2.h,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Documents",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        docListIsEmpty
            ? Card(
          elevation: 2,
          color: Colors.white,
          child: Container(
            alignment: Alignment.center,
            height: 25.h,
            width: 100.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_copy_outlined,
                      size: 32.sp,
                    ),
                    Text(
                      "Upload documents",
                      style: TextStyle(fontSize: 12.sp),
                    )
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    List<Map<String, dynamic>> result = await pickMultipleDocuments();

                    if (result.isNotEmpty){
                      _listingController.docListStrDyn.addAll(result);

                      List<Uint8List> docBytesFiles = _listingController
                          .docListStrDyn.map((fileMap) =>
                      fileMap['bytes'] as Uint8List).toList();

                      _listingController.docPathList.value = await getFilePathsFromDocByte(docBytesFiles);

                      setState(() {
                        if (_listingController.docListStrDyn.isNotEmpty
                        && _listingController.docPathList.isNotEmpty) {
                          docListIsEmpty = false;
                        }
                      });
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF005555)),
                      foregroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white)),
                  child: const Text("Upload"),
                ),
                const Spacer()
              ],
            ),
          ),
        )
            : Column(children: [
          Obx(() {
            return SizedBox(
              height: 20.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _listingController.docPathList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: <Widget>[
                      SizedBox(
                        width: 30.w,
                        child: PDFView(
                          filePath: _listingController.docPathList[index],
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: true,
                          pageFling: false,
                          onRender: (_pages) {
                            setState(() {
                              pages = _pages;
                              isReady = true;
                            });
                          },
                          onError: (error) {
                            print(error.toString());
                          },
                          onPageError: (page, error) {
                            print('$page: ${error.toString()}');
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            print('File path: ${_listingController
                                .docPathList[index]}');
                            _controller.complete(pdfViewController);
                          },
                          onPageChanged: (int? page, int? total) {
                            print('page change: $page/$total');
                          },
                        ),
                      ),
                      Positioned(
                        top: 0.3.h,
                        left: 1.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            // Choose a color that contrasts with the icon color
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              // Define your action here
                              setState(() {
                                _listingController.docPathList.removeAt(index);
                                _listingController.docListStrDyn.removeAt(index);
                                if (_listingController.docListStrDyn.isEmpty &&
                                    _listingController.docPathList.isEmpty) {
                                  docListIsEmpty = true;
                                }
                                _listingController.update();
                              });
                            },
                            child: IconTheme(
                              data: IconThemeData(
                                  size: 18.sp, color: Colors.black),
                              child: const FaIcon(
                                FontAwesomeIcons.circleXmark,
                                // size: 10.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  // Don't add a separator after the last item
                  if (index == _listingController.docPathList!.length - 1) {
                    return const SizedBox.shrink();
                  }
                  // Add a SizedBox with your desired width for other items
                  return SizedBox(width: 2.w);
                },
              ),
            );
          }),
          SizedBox(
            height: 2.h,
          ),
          Row(
            children: [
              ElevatedButton.icon(
                icon: IconTheme(
                  data: IconThemeData(size: 8.sp, color: Colors.white),
                  child: const FaIcon(FontAwesomeIcons.plus),
                ),
                label: Text(
                  'Add',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 8.sp),
                ),
                onPressed: () async {
                  List<Map<String,dynamic>> result = await pickMultipleDocuments();


                  List<String> docResult = await getFilePathsFromDocByte(
                      result.map((fileMap) =>
                      fileMap['bytes'] as Uint8List).toList()
                  );

                  if (result.isNotEmpty) {
                    _listingController.docListStrDyn.addAll(result);
                    List<Uint8List> docResult = result.map((fileMap) =>
                    fileMap['bytes'] as Uint8List).toList();
                    List<String> docPath = await getFilePathsFromDocByte(docResult);
                    _listingController.docPathList.addAll(docPath);
                    //
                    // setState(() {
                    // });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF005555),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  minimumSize: Size(5.w, 3.h),
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              ElevatedButton.icon(
                icon: IconTheme(
                  data: IconThemeData(size: 8.sp, color: Colors.white),
                  child: const FaIcon(FontAwesomeIcons.trash),
                ),
                label: Text(
                  'Delete All',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 8.sp),
                ),
                onPressed: () {
                  _listingController.docPathList.clear();
                  _listingController.docListStrDyn.clear();
                  setState(() {
                    docListIsEmpty = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 1.h),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF005555),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    minimumSize: Size(5.w, 3.h)),
              ),
            ],
          )
        ])
      ]),
    );
  }
}

