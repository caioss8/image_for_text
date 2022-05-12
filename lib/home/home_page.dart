import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool textScan = false;
  String text = '';
  XFile? imageFile;

  void getImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        textScan = true;
        imageFile = pickedImage;
        getTextImage(pickedImage);
        setState(() {});
      }
    } catch (e) {
      textScan = false;
      imageFile = null;
      text = 'Failed';
      setState(() {});
    }
  }

  void getImageCam() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        textScan = true;
        imageFile = pickedImage;
        getTextImage(pickedImage);
        setState(() {});
      }
    } catch (e) {
      textScan = false;
      imageFile = null;
      text = 'Failed';
      setState(() {});
    }
  }

  void getTextImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDector.processImage(inputImage);
    await textDector.close();
    text = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text = text + line.text + "\n";
        setState(() {});
      }
    }
    textScan = false;
  }

  void clearAll() {
    text = '';
    imageFile = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Copiar texto da Imagem'), centerTitle: true),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageFile == null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.grey,
                        width: 300,
                        height: 300,
                        child: const Center(
                          child: Text(
                            'Adicione uma imagem!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(width: 300, height: 300, child: Image.file(File(imageFile!.path))),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                            ),
                            onPressed: () {
                              getImageCam();
                            },
                            child: Row(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Icon(Icons.camera_alt_sharp),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('Tire uma Foto'),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                            ),
                            onPressed: () {
                              getImage();
                            },
                            child: Row(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Icon(Icons.image),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Entre na galeria',
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              if (text != '')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: SingleChildScrollView(
                      child: Text('TEXTO COPIADO:\n $text'),
                    ),
                  ),
                ),
              if (text != '')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        onPressed: () {
                          clearAll();
                        },
                        child: const Text('Limpar Tudo')),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Texto Copiado Com sucesso!'),
                          backgroundColor: Colors.green,
                        ));
                      },
                      child: const Text('Copiar Texto'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
