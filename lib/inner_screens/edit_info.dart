import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase/firebase.dart' as fb;

class EditInfoScreen extends StatefulWidget {
  const EditInfoScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  final String id, title, price, imageUrl,description;

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Title and price controllers
  late final TextEditingController _titleController, _priceController,_descriptionController;

  late String percToShow;

  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;

  @override
  void initState() {
    // set the price and title initial values and initialize the controllers
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);

    _imageUrl = widget.imageUrl;

    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controllers
    _priceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // this method to edit and re-upload the images,title and price from admin app to firebase
  void _updateProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        Uri? imageUri;
        setState(() {});
        if (_pickedImage != null) {
          fb.StorageReference storageRef = fb
              .storage()
              .ref()
              .child('productsImages')
              .child(widget.id + 'jpg');
          final fb.UploadTaskSnapshot uploadTaskSnapshot =
              await storageRef.put(kIsWeb ? webImage : _pickedImage).future;
          imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
        }
        await FirebaseFirestore.instance
            .collection('information')
            .doc(widget.id)
            .update({
          'title': _titleController.text,
          'description' :_descriptionController.text,
          'price': _priceController.text,
          'imageUrl':
              _pickedImage == null ? widget.imageUrl : imageUri.toString(),
        });
        // this method to show massage after update
        await Fluttertoast.showToast(
          msg: "Information has been updated",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {});
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {});
      } finally {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    return Scaffold(
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Text('Edit this product'),
              Container(
                width: size.width > 650 ? 650 : size.width,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextWidget(
                        text: 'Product title*',
                        color: color,
                        isTitle: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // to edit title
                      TextFormField(
                        controller: _titleController,
                        key: const ValueKey('Title'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a Title';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _scaffoldColor,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: color,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // to edit description
                      TextWidget(
                        text: 'Product description',
                        color: color,
                        isTitle: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        key: const ValueKey('Description'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a Description';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _scaffoldColor,
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: color,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FittedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'Skin Regime',
                                    color: color,
                                    isTitle: true,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: 100,
                                    // to edit price
                                    child: TextFormField(
                                      controller: _priceController,
                                      key: const ValueKey('Price \$'),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Price is missed';
                                        }
                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: _scaffoldColor,
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                height:
                                    size.width > 650 ? 350 : size.width * 0.45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  // to edit image
                                  child: _pickedImage == null
                                      ? Image.network(_imageUrl)
                                      : (kIsWeb)
                                          ? Image.memory(
                                              webImage,
                                              fit: BoxFit.fill,
                                            )
                                          : Image.file(
                                              _pickedImage!,
                                              fit: BoxFit.fill,
                                            ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: TextButton(
                                      onPressed: () {
                                        _pickImage();
                                      },
                                      child: TextWidget(
                                        text: 'Update image',
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ButtonsWidget(
                              onPressed: () async {
                                GlobalMethods.warningDialog(
                                    title: 'Delete?',
                                    subtitle: 'Press okay to confirm',
                                    fct: () async {
                                      await FirebaseFirestore.instance
                                          .collection('products')
                                          .doc(widget.id)
                                          .delete();
                                      await Fluttertoast.showToast(
                                        msg: "Product has been deleted",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                      );
                                      while (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    context: context);
                              },
                              text: 'Delete',
                              icon: IconlyBold.danger,
                              backgroundColor: Colors.red.shade700,
                            ),
                            ButtonsWidget(
                              onPressed: () {
                                _updateProduct();
                              },
                              text: 'Update',
                              icon: IconlyBold.setting,
                              backgroundColor: Colors.blue,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }

  Future<void> _pickImage() async {
    // MOBILE
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var selected = File(image.path);

        setState(() {
          _pickedImage = selected;
        });
      } else {
        log('No file selected');
        // showToast("No file selected");
      }
    }
    // WEB
    else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _pickedImage = File("a");
          webImage = f;
        });
      } else {
        log('No file selected');
      }
    } else {
      log('Perm not granted');
    }
  }
}
