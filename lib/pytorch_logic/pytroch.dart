
import 'dart:io';

import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class PytorchLogic{
  Future<File> imageToFile(img.Image image, String filename) async {
    // Get the temporary directory.
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // Create a new file in the temporary directory.
    File file = File('$tempPath/$filename');

    // Encode the image to JPEG and write it to the file.
    await file.writeAsBytes(img.encodeJpg(image));

    return file;
  }
  Future<img.Image?> preprocessImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes(); // This directly returns Uint8List
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // Resize the image to 256x256.
      img.Image resizedImage = img.copyResize(originalImage, width: 256, height: 256);

      // Crop the resized image to 224x224, starting from the center.
      int offsetX = (resizedImage.width - 224) ~/ 2;
      int offsetY = (resizedImage.height - 224) ~/ 2;
      img.Image croppedImage = img.copyCrop(resizedImage, x: offsetX, y: offsetY, width: 224, height: 224);

      return croppedImage; // Return the cropped image
    } else {
      return null;
    }
  }

}