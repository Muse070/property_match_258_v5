import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import the 'dart:io' library for file operations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Import http
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/edit_property_controller.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../../utils/pick_image.dart';

class ImagesStep extends StatefulWidget {
  final PropertyModel property;

  const ImagesStep({super.key, required this.property});

  @override
  State<ImagesStep> createState() => _ImagesStepState();
}

class _ImagesStepState extends State<ImagesStep> {
  EditPropertyController _editPropertyController =
      Get.find<EditPropertyController>();

  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  bool imageListIsEmpty = true;
  bool docListIsEmpty = true;

  int pages = 0;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    if (_editPropertyController.imageListStrDyn.isNotEmpty) {
      imageListIsEmpty = false;
    }

    if (_editPropertyController.docListStrDyn.isNotEmpty &&
        _editPropertyController.docPathList.isNotEmpty) {
      setState(() {
        docListIsEmpty = false;
      });
    }

    _editPropertyController.prepareImagesForDisplay();

  }

  bool validateSelection() {
    return _editPropertyController.imageListStrDyn.isNotEmpty;
  }

  Future<Uint8List> ed(String path) async {
    if (path.startsWith('http')) {
      final response = await http.get(Uri.parse(path));
      return response.bodyBytes;
    } else {
      // Logic for fetching from a local file path
      final file = File(path); // Create a File object
      if (await file.exists()) {
        return file.readAsBytes(); // Read the file as bytes
      } else {
        throw Exception("File not found: $path"); // Handle file not found case
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: SizedBox(
        height: 70.h,
        child: SingleChildScrollView(
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
                              try {
                                final List<Map<String, dynamic>> result =
                                    await pickMultipleImagesAndVideos();
                                print(result);

                                if (result.isNotEmpty) {
                                  imageListIsEmpty = false;
                                  print(
                                      "The old image Str Dyn is: ${_editPropertyController.imageListStrDyn}");
                                  List<Uint8List> uint8Lists = result
                                      .where((map) => map['bytes']
                                          is Uint8List) // Keep only maps where 'bytes' is Uint8List
                                      .map((map) => map['bytes']
                                          as Uint8List) // Extract the Uint8List values
                                      .toList();

                                  print("And your result is: $result");
                                  setState(() {
                                    _editPropertyController.newImages.addAll(result);
                                  });

                                  for (var image in result) {
                                    setState(() {
                                      _editPropertyController.imageListStrDyn
                                          .add({
                                        'bytes': image['bytes'] is Uint8List
                                            ? base64Encode(image['bytes'])
                                            : image['bytes'],
                                        'extension': image['extension'],
                                      }.cast<String, String>() // Explicit cast
                                              );
                                      print("image is: ${image['bytes']}");
                                    });
                                  }
                                  print(
                                      "The new image Str Dyn is: ${_editPropertyController.imageListStrDyn}");
                                }
                              } on PlatformException catch (e) {
                                print("Error selecting images/videos: $e");
                                Get.snackbar(
                                    "Error", "Could not select images/videos.",
                                    snackPosition: SnackPosition.BOTTOM);
                              } catch (e) {
                                // Catch general exceptions
                                print("Unexpected error: $e");
                                Get.snackbar(
                                    "Error", "An unexpected error occurred.",
                                    snackPosition: SnackPosition.BOTTOM);
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
                                  for (var i = 0;
                                      i <
                                          _editPropertyController
                                              .newImages.length;
                                      i++) ...[
                                    Stack(
                                      children: [
                                        FutureBuilder<dynamic>(
                                            future: _getImageData(
                                                _editPropertyController.newImages[i]['bytes']).then((imageData) {
                                              print("Result of _getImageData: $imageData"); // Log the imageData directly
                                              if (imageData != null) {
                                                print("Image Data Type: ${imageData.runtimeType}"); // Log the type of imageData
                                                print("Image Data Length: ${imageData.lengthInBytes}"); // Log the size in bytes
                                              } else {
                                                print("imageData is null");
                                              }
                                              return imageData;
                                            }),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                print("I can finaly print img Str dyn: ${_editPropertyController.imageListStrDyn}");
                                                return Image.memory( // Always use Image.memory
                                                  snapshot.data!,
                                                  width: 18.h,
                                                  height: 18.h,
                                                  fit: BoxFit.cover,
                                                );

                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        "Error loading Image: ${snapshot.error}"));
                                              } else {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator()); // Show loading
                                              }
                                              ;
                                            }),
                                        // Invalid format placeholder
                                        Positioned(
                                          top: 0.3.h,
                                          left: 1.w,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              // Choose a color that contrasts with the icon color
                                              shape: BoxShape.circle,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (i <
                                                      _editPropertyController
                                                          .imageListStrDyn
                                                          .length && i < _editPropertyController
                                                      .newImages
                                                      .length) {
                                                    _editPropertyController
                                                        .imageListStrDyn
                                                        .removeAt(i);
                                                    _editPropertyController
                                                        .newImages
                                                        .removeAt(i);
                                                    if (_editPropertyController
                                                        .imageListStrDyn
                                                        .isEmpty && _editPropertyController.newImages.isEmpty) {
                                                      imageListIsEmpty = true;
                                                    }
                                                  }
                                                });
                                              },
                                              child: IconTheme(
                                                data: IconThemeData(
                                                    size: 18.sp,
                                                    color: Colors.black),
                                                child: const FaIcon(
                                                  FontAwesomeIcons.circleXmark,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (i !=
                                        _editPropertyController
                                                .newImages.length -
                                            1)
                                      SizedBox(
                                        width: 2.5.w,
                                      )
                                  ]
                                ],
                              ),
                            )),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: IconTheme(
                                data: IconThemeData(
                                    size: 8.sp, color: Colors.white),
                                child: const FaIcon(FontAwesomeIcons.plus),
                              ),
                              label: Text(
                                'Add',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8.sp),
                              ),
                              onPressed: () async {
                                List<Map<String, dynamic>> result =
                                    await pickMultipleImagesAndVideos();

                                if (result.isNotEmpty) {

                                  print("Ending newImages");


                                    setState(() {
                                      _editPropertyController.newImages.addAll(result);

                                    });

                                  print("newImages are: ${_editPropertyController.newImages}");


                                  for (var image in result) {
                                    setState(() {
                                      _editPropertyController.imageListStrDyn
                                          .add({
                                        'bytes': image['bytes'] is Uint8List
                                            ? base64Encode(image['bytes'])
                                            : image['bytes'],
                                        'extension': image['extension'],
                                      }.cast<String, String>() // Explicit cast
                                              );

                                      imageListIsEmpty = false;
                                    });
                                  }
                                  print("New images are: ${_editPropertyController.newImages}");
                                  print("New images should conatain all the images");
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
                                data: IconThemeData(
                                    size: 8.sp, color: Colors.white),
                                child: const FaIcon(FontAwesomeIcons.trash),
                              ),
                              label: Text(
                                'Delete All',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8.sp),
                              ),
                              onPressed: () {
                                setState(() {
                                  _editPropertyController.imageListStrDyn
                                      .clear();
                                  _editPropertyController.newImages.clear();
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
                              List<Map<String, dynamic>> result =
                                  await pickMultipleDocuments();

                              print(
                                  "This is the current doc list. I should be empty: ${_editPropertyController.docListStrDyn}");

                              if (result.isNotEmpty) {
// Filter out the Uint8List values
                                List<Uint8List> uint8Lists = result
                                    .where((map) => map['bytes']
                                        is Uint8List) // Keep only maps where 'bytes' is Uint8List
                                    .map((map) => map['bytes']
                                        as Uint8List) // Extract the Uint8List values
                                    .toList();

                                var docPaths =
                                    await getFilePathsFromDocByte(uint8Lists);
                                print("And your result is: $result");

                                for (var doc in result) {
                                  setState(() {
                                    _editPropertyController.docListStrDyn.add({
                                      'bytes': doc['bytes'] is Uint8List
                                          ? base64Encode(doc['bytes'])
                                          : doc['bytes'],
                                      'extension': doc['extension']
                                    }.cast<String, String>() // Explicit cast
                                        );
                                    print("doc is: ${doc['bytes']}");
                                  });
                                }

                                print(
                                    "This is the current doc list. Now I should have a value: ${_editPropertyController.docListStrDyn}");

                                print(
                                    "New doclist is: ${_editPropertyController.docListStrDyn}");

                                // _listingController.updateImageListStrDyn(mediaMapList);
                                setState(() {
                                  docListIsEmpty = false;
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
                      print(
                          "docListStrDyn length: ${_editPropertyController.docListStrDyn.length}");
                      return SizedBox(
                        height: 20.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _editPropertyController.docListStrDyn.length,
                          itemBuilder: (context, index) {
                            final document =
                                _editPropertyController.docListStrDyn[index];
                            final docBytes = document['bytes'];
                            print(
                                "The pdf link is: ${document['bytes']}.${document['extension']}");

                            // Create a unique Completer for each PDF document
                            final pdfController =
                                Completer<PDFViewController>();

                            return Stack(
                              children: <Widget>[
                                SizedBox(
                                  width: 30.w,
                                  child: FutureBuilder<Uint8List>(
                                      future: _getPdfData(docBytes),
                                      // Use the new function
                                      // Use directly if 'bytes' is Uint8List
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data is Uint8List) {
                                            return PDFView(
                                              pdfData: snapshot.data!,
                                              enableSwipe: true,
                                              swipeHorizontal: true,
                                              autoSpacing: true,
                                              pageFling: false,
                                              onRender: (_pages) {
                                                setState(() {
                                                  pages = _pages ?? 0;
                                                  isReady = true;
                                                });
                                              },
                                              onError: (error) {
                                                print(error.toString());
                                              },
                                              onPageError: (page, error) {
                                                print(
                                                    '$page: ${error.toString()}');
                                              },
                                              onViewCreated: (PDFViewController pdfViewController) {
                                                // print(
                                                //     'File path: ${_editPropertyController.docPathList[index]}');
                                                // Complete the controller only if it hasn't been completed before
                                                if (!pdfController
                                                    .isCompleted) {
                                                  pdfController.complete(
                                                      pdfViewController);
                                                }
                                              },
                                              onPageChanged:
                                                  (int? page, int? total) {
                                                print(
                                                    'page change: $page/$total');
                                              },
                                            );
                                          } else if (snapshot.data is String) {
                                            return PDFView(
                                              pdfData: snapshot.data!,
                                              enableSwipe: true,
                                              swipeHorizontal: true,
                                              autoSpacing: true,
                                              pageFling: false,
                                              onRender: (_pages) {
                                                setState(() {
                                                  pages = _pages ?? 0;
                                                  isReady = true;
                                                });
                                              },
                                              onError: (error) {
                                                print(error.toString());
                                              },
                                              onPageError: (page, error) {
                                                print(
                                                    '$page: ${error.toString()}');
                                              },
                                              onViewCreated: (PDFViewController
                                                  pdfViewController) {
                                                print(
                                                    'File path: ${_editPropertyController.docPathList[index]}');
                                                // Complete the controller only if it hasn't been completed before
                                                if (!pdfController
                                                    .isCompleted) {
                                                  pdfController.complete(
                                                      pdfViewController);
                                                }
                                              },
                                              onPageChanged:
                                                  (int? page, int? total) {
                                                print(
                                                    'page change: $page/$total');
                                              },
                                            );
                                          } else {
                                            return Text(
                                                "Unsupported data type: ${snapshot.data.runtimeType}");
                                          }
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  "Error loading PDF: ${snapshot.error}"));
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator()); // Show loading
                                        }
                                      }),
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
                                          _editPropertyController.docListStrDyn
                                              .removeAt(index);
                                          // _editPropertyController.docListStrDyn
                                          //     .removeAt(index);
                                          if (_editPropertyController
                                              .docListStrDyn.isEmpty) {
                                            docListIsEmpty = true;
                                          }
                                          _editPropertyController.update();
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
                            if (index ==
                                _editPropertyController.docPathList!.length -
                                    1) {
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
                            data:
                                IconThemeData(size: 8.sp, color: Colors.white),
                            child: const FaIcon(FontAwesomeIcons.plus),
                          ),
                          label: Text(
                            'Add',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 8.sp),
                          ),
                          onPressed: () async {
                            List<Map<String, dynamic>> result =
                                await pickMultipleDocuments();

                            if (result.isNotEmpty) {
                              for (var doc in result) {
                                setState(() {
                                  print("doc bytes: ${doc['bytes']}");
                                  print("doc extension: ${doc['extension']}");
                                  print(
                                      "Type: ${doc.runtimeType}"); // Print the type

                                  _editPropertyController.docListStrDyn.add({
                                    'bytes': doc['bytes'] is Uint8List
                                        ? base64Encode(doc['bytes'])
                                        : doc['bytes'],
                                    'extension': doc['extension']
                                  } // Explicit cast
                                      );

                                  // Update docPathList
                                  _editPropertyController.docPathList.value =
                                      _editPropertyController.docListStrDyn
                                          .map((doc) =>
                                              '${doc['bytes']}${doc['extension']}')
                                          .cast<String>()
                                          .toList();

                                  docListIsEmpty = false;
                                });
                              }

                              print(
                                  "I just added these links: ${_editPropertyController.docListStrDyn}");
                            }
                            print(
                                "I just added these links: ${_editPropertyController.docPathList}");
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
                            data:
                                IconThemeData(size: 8.sp, color: Colors.white),
                            child: const FaIcon(FontAwesomeIcons.trash),
                          ),
                          label: Text(
                            'Delete All',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 8.sp),
                          ),
                          onPressed: () {
                            _editPropertyController.docPathList.clear();
                            _editPropertyController.docListStrDyn.clear();
                            setState(() {
                              docListIsEmpty = true;
                            });
                            print(
                                "Documents after deletion: ${_editPropertyController.docListStrDyn}");
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
        ),
      ),
    );
  }

  // Helper function to get PDF data from either a URL or Base64 string
  Future<Uint8List> _getPdfData(dynamic data) async {
    if (data is Uint8List) {
      return data; // Already Uint8List data
    } else if (data is String) {
      try {
        Uri uri = Uri.parse(data);
        if (uri.isAbsolute) {
          // If it's a valid URL, download
          return await ed(data);
        } else {
          // If it's not a URL, assume Base64 and decode
          return base64Decode(data);
        }
      } catch (e) {
        throw Exception("Invalid data format: $e");
      }
    } else {
      throw ArgumentError("Unsupported data type: ${data.runtimeType}");
    }
  }

  Future<Uint8List?> _getImageData(dynamic data) async {
    if (data is Uint8List) {
      return data; // Already Uint8List
    } else if (data is String) {
      if (_editPropertyController.isFirebaseStorageUrl(data)) {
        try {
          final response = await http.get(Uri.parse(data));
          if (response.statusCode == 200) {
            return response.bodyBytes; // Fetch and return Uint8List from URL
          } else {
            print('Error fetching image from URL: ${response.statusCode}');
            return null; // Or return a placeholder image
          }
        } catch (e) {
          print('Error fetching image from URL: $e');
          return null; // Or return a placeholder image
        }
      } else if (_editPropertyController.isBase64(data)) {
        try {
          return base64Decode(data);
        } catch (e) {
          print('Error decoding Base64 image data: $e');
          return null; // Or return a placeholder image
        }
      } else {
        print('Invalid image data format');
        return null; // Or return a placeholder image
      }
    } else {
      print('Unsupported image data type: ${data.runtimeType}');
      return null; // Or return a placeholder image
    }
  }
}
