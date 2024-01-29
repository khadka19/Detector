import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.cameras})
      : super(key: key);
  final List<CameraDescription> cameras;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  List? _classifiedResult;
  bool female = false;
  String pronoun = "He";
  @override
  void initState() {
    super.initState();
    loadImageModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Cat/Dog Identifier"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    border: Border.all(color: Colors.white),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(2, 2),
                        spreadRadius: 2,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: (_imageFile != null)
                      ? Image.file(_imageFile!)
                      : Image.asset("assets/addPhoto.png")),
              InkWell(
                onTap: () {
                  selectImage();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            "Select Image",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(FontAwesome.image)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  openCamera();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            "Capture Image",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(FontAwesome.camera)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  // ignore: unnecessary_null_comparison
                  children: _classifiedResult != null
                      ? _classifiedResult!.map((result) {
                          return Card(
                            elevation: 0.0,
                            color: Colors.lightBlue,
                            child: Container(
                              width: 300,
                              margin: EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "$pronoun is :${result["label"]}",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future loadImageModel() async {
    Tflite.close();
    String result;
    result = (await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ))!;
    print(result);
    if (_classifiedResult == "Prakriti") {
      female = true;
      pronoun = "She";
    }
  }

  Future selectImage() async {
    final picker = ImagePicker();
    var image =
        await picker.pickImage(source: ImageSource.gallery, maxHeight: 300);
    classifyImage(image);
  }

  Future openCamera() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 300,
    );
    classifyImage(image);
  }

  Future captureImage() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.camera);
    classifyImage(image);
  }

  Future classifyImage(image) async {
    _classifiedResult = [];
    // Run tensorflowlite image classification model on the image
    print("classification start $image");
    final List? result = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("classification done");
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        _classifiedResult = result!;
      } else {
        print('No image selected.');
      }
    });
  }
}
