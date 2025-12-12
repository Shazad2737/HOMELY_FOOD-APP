import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/widgets/photos_form/view_image_page.dart';
import 'package:flutter/material.dart';

/// Wrapper for images with a close button to remove them.
class ImageWidget extends StatelessWidget {
  const ImageWidget({
    required this.image,
    required this.onImageChanged,
    super.key,
  });

  final XFile image;
  // final VoidCallback onImageRemoved;

  /// Callback when the image is removed or edited.
  final void Function(XFile? image) onImageChanged;

  @override
  Widget build(BuildContext context) {
    // final decodedImage = decodeImageFromList(file.readAsBytesSync());
    // final imageFile = File(image.path);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.grey100,
        ),
        // borderRadius: BorderRadius.circular(16),
      ),
      // constraints: const BoxConstraints(
      //   maxHeight: 100,
      //   minWidth: 100,
      // ),
      // width: imageWidth,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context)
              .push(
            ViewImagePage.route(image: image),
          )
              .then((value) {
            if (value != null) {
              onImageChanged(value);
            } else {
              onImageChanged(null);
            }
          });
        },
        child: Stack(
          children: [
            // Image.file(
            //   File(image!.path),
            //   height: 100,
            // ),
            Hero(
              tag: image.path,
              child: Image.file(
                // imageFile,
                File(image.path),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: () {
                  onImageChanged(null);
                },
                child: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 12,
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: 6,
            //   left: 6,
            //   child: InkWell(
            //     onTap: () async {
            //       // final croppedFile = await ImageCropper().cropImage(
            //       //   sourcePath: image!.path,
            //       // );

            //       // if (croppedFile != null) {
            //       //   onImageChanged(XFile(croppedFile.path));
            //       // }
            //       // final croppedImage =
            //     },
            //     child: const CircleAvatar(
            //       backgroundColor: AppColors.base100,
            //       radius: 12,
            //       child: Center(
            //         child: Icon(
            //           Icons.edit,
            //           color: AppColors.white,
            //           size: 16,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
