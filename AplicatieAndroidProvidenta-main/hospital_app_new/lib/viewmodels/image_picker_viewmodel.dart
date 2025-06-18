import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerViewModel extends ChangeNotifier {
  final List<XFile> images = [];
  final int maxImages = 5;


  // Method to add an image
  void addImage(XFile image) {
    images.add(image);
    notifyListeners();
  }

  List<XFile> get getImages => List.unmodifiable(images);

  Future<void> pickImages(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        if (images.length + 1 > maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maxim 5 imagini pot fi adaugate')),
          );
          return;
        }

        images.add(picked);
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void clearImages() {
    images.clear();
    notifyListeners();
  }
}