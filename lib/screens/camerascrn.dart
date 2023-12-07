import 'dart:io';

import 'package:cameraapp/screens/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScrn extends StatefulWidget {
  const CameraScrn({Key? key}) : super(key: key);

  @override
  State<CameraScrn> createState() => _CameraScrnState();
}

File? selectedImage;
List<Map<String, dynamic>> imageList = [];

class _CameraScrnState extends State<CameraScrn> {
  @override
  void initState() {
    initializeSelectedImage();

    super.initState();
  }

  Future<void> initializeSelectedImage() async {
    File? returnImage = await getImageFromCamera(context);
    if (returnImage != null) {
      insertImagetoDatabase(returnImage.path);
    }
    fetchImage();
  }

  Future<void> fetchImage() async {
    List<Map<String, dynamic>> listFroDatabase = await getImageFromDatabase();
    setState(() {
      imageList = listFroDatabase;
    });
  }

  Future<File?> getImageFromCamera(BuildContext context) async {
    File? image;
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        image = File(pickedImage
            .path); // Change this line to add the picked image to the list
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, e.toString(), Colors.red);
    }
    return image;
  }

  void showSnackbar(BuildContext context, String content, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              initializeSelectedImage();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
          ),
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            final imageMap = imageList[index];
            final fileImage = File(imageMap['imageSrc']);
            final id = imageMap['id'];
            return Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Image.file(
                          fileImage,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: Image.file(
                        fileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 75,
                      left: 45,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: SizedBox(
                                      height: 150,
                                      width: 220,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Do you want to delete?',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 30),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      await deleteImageFromDatabase(
                                                          id);
                                                      // ignore: use_build_context_synchronously
                                                      Navigator.of(context)
                                                          .pop();

                                                      fetchImage();
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  content: Text(
                                                                      'image successfully deleted')));
                                                    },
                                                    child: const Text('Yes')),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No'))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 20,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
