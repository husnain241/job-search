import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditUserDataPage extends StatefulWidget {
  @override
  _EditUserDataPageState createState() => _EditUserDataPageState();
}

class _EditUserDataPageState extends State<EditUserDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  final storage = FirebaseStorage.instance;
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDataSnapshot =
          await _firestore.collection('userdata').doc(user.uid).get();

      if (userDataSnapshot.exists) {
        final data = userDataSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ??
              ''; // Use empty string as a default if 'name' is null.
          _bioController.text = data['bio'] ??
              ''; // Use empty string as a default if 'bio' is null.
        });
      }
    }
  }

  Future<void> saveUserData() async {
    final User? user = _auth.currentUser;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      return;
    }
    String downloadURL = '';

    if (_imageFile != null) {
      try {
        final videoStorageRef =
            storage.ref().child('user_videos/${user!.uid}/');

        final uploadTask =
            videoStorageRef.child('profile.jpg').putFile(_imageFile!);

        await uploadTask;
        downloadURL =
            await videoStorageRef.child('profile.jpg').getDownloadURL();

        print('Image uploaded. URL: $downloadURL');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    if (user != null) {
      Map<String, dynamic> updatedData = {};
      updatedData['profileimg'] = downloadURL;
      if (_nameController.text.isNotEmpty) {
        updatedData['name'] = _nameController.text;
      }

      if (_bioController.text.isNotEmpty) {
        updatedData['bio'] = _bioController.text;
      }

      if (updatedData.isNotEmpty) {
        await _firestore
            .collection('userdata')
            .doc(user.uid)
            .update(updatedData);
        await _firestore.collection('userdata').doc(user.uid).update({
          'newField': downloadURL,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User data updated successfully!'),
          duration: Duration(seconds: 2),
        ));

        Future.delayed(Duration(seconds: 0), () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit User Name/Bio',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 3, 53, 41),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _imageFile != null
                    ? Container(height: 50, child: Image.file(_imageFile!))
                    : Text('No image'),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text('Pick an Image'),
                ),
              ],
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.all(16.0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                contentPadding: EdgeInsets.all(16.0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await saveUserData();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 3, 53, 41),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(16.0),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
