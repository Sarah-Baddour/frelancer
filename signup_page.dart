import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end_project/LoginPage/login_screen.dart';
import 'package:end_project/Services/global_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/global_variable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  bool _obscuretext = false;
  bool _isloading = false;
  final TextEditingController _fullNameController =
      TextEditingController(text: '');
  final TextEditingController _emailController =
      TextEditingController(text: '');
  final TextEditingController _passController = TextEditingController(text: '');
  final TextEditingController _phoneController =
      TextEditingController(text: '');
  final TextEditingController _locationController =
      TextEditingController(text: '');
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();
  late Animation<double> _animation;
  late AnimationController _animationController;
  final GlobalKey<FormState> _signUpFormKey = GlobalKey();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _passController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _phoneFocusNode.dispose();
    _positionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(
            (animationStatus) {
              if (animationStatus == AnimationStatus.completed) {
                _animationController.reset();
                _animationController.forward();
              }
            },
          );
    _animationController.forward();
    super.initState();
  }

  void _showImageDialoge() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Please choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    setState(() {});
    Navigator.pop(context);
  }
  //كود الكورس
  // void _getFromGallery() async {
  //   XFile? pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   _cropImage(pickedFile!.path);
  //   setState(() {

  //   });
  //   Navigator.pop(context);
  // }

  //كود الصورة تبع تابع القص
  ///
  // void _cropImage(filepath) async {
  //   CroppedFile? croppedImage = await ImageCropper()
  //       .cropImage(sourcePath: filepath, maxHeight: 1082, maxWidth: 1080);
  //   if (croppedImage != null) {
  //     setState(() {
  //       imageFile = File(croppedImage.path);
  //     });
  //   }
  // }

////////////كود الشات الاول مشكلتوا ما بيبدل الصورة مرتين
  ///
// Future<void> _cropImage(String filepath) async {
//   final originalFile = File(filepath);
//   final imageBytes = await originalFile.readAsBytes();

//   // اقتصاص بسيط باستخدام مكتبة image
//   final image = img.decodeImage(imageBytes)!;
//   final cropped = img.copyCrop(
//     image,
//     x: (image.width - 1080) ~/ 2,
//     y: (image.height - 1082) ~/ 2,
//     width: 1080,
//     height: 1082,
//   );

//   final directory = await getTemporaryDirectory();
//   final outputFile = File('${directory.path}/cropped.jpg');
//   await outputFile.writeAsBytes(img.encodeJpg(cropped));
//   if(outputFile != null){
//    setState(() => imageFile = outputFile);
//   }

// }
////////////////////////////////////////////////////////////////////

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
    Navigator.pop(context);
  }

  Future<void> _cropImage(String filepath) async {
    final originalFile = File(filepath);
    final imageBytes = await originalFile.readAsBytes();

    // اقتصاص الصورة
    final image = img.decodeImage(imageBytes)!;
    final cropped = img.copyCrop(
      image,
      x: (image.width - 1080) ~/ 2,
      y: (image.height - 1082) ~/ 2,
      width: 1080,
      height: 1082,
    );

    // حفظ الصورة المؤقتة
    final directory = await getTemporaryDirectory();
    final uniqueFileName =
        'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg'; // اسم ملف فريد
    final outputFile = File('${directory.path}/$uniqueFileName');
    await outputFile.writeAsBytes(img.encodeJpg(cropped));

    setState(() {
      imageFile = outputFile;
    });
  }

  void _submitform() async {
    final isvalid = _signUpFormKey.currentState!.validate();
    if (isvalid) {
      if (imageFile == null) {
        GlobalMethods.showErrorDialog(
            error: "Please Enter your Image", ctx: context);
        return;
      }
      setState(() {
        _isloading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim().toLowerCase(),
            password: _passController.text.trim());
        final User? user = _auth.currentUser;
        final uid = user!.uid;
        // final ref = FirebaseStorage.instance.ref().child("UserImages");
        FirebaseFirestore.instance.collection("users").doc(uid).set({
          "id": uid,
          "name": _fullNameController.text,
          "email": _emailController.text,
          "phoneNumber": _phoneController.text,
          "location": _locationController.text,
          "createdAt": Timestamp.now()
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isloading = false;
        });
        GlobalMethods.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            loginUrlImage2,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showImageDialoge();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.cyanAccent),
                                    borderRadius: BorderRadius.circular(20)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? const Icon(
                                          Icons.camera_enhance_sharp,
                                          color: Colors.cyan,
                                          size: 30,
                                        )
                                      : Image.file(
                                          imageFile!,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_emailFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _fullNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This Field is missing";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: "Full name / Company name",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains("@")) {
                                return "Please enter a valid Email address";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: "Email ",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: !_obscuretext,
                            focusNode: _passFocusNode,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_phoneFocusNode),
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passController,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 8) {
                                return "Please enter a valid Password";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscuretext = !_obscuretext;
                                    });
                                  },
                                  child: Icon(
                                      color: Colors.white,
                                      _obscuretext
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                ),
                                hintText: "Password ",
                                hintStyle: const TextStyle(color: Colors.white),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            focusNode: _phoneFocusNode,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_positionFocusNode),
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field is missing";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: "Phone Number ",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            focusNode: _positionFocusNode,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_positionFocusNode),
                            keyboardType: TextInputType.text,
                            controller: _locationController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field is missing";
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: "Company Address ",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          _isloading
                              ? const Center(
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    _submitform();
                                  },
                                  color: Colors.cyan,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Sign Up",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 40,
                          ),
                          Center(
                            child: RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                text: "Already have an account ?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const TextSpan(text: "        "),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : null,
                                text: "Log in",
                                style: const TextStyle(
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ])),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
