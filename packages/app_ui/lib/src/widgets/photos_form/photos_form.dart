import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/widgets/photos_form/add_photo_button.dart';
import 'package:app_ui/src/widgets/photos_form/image_widget.dart';
import 'package:app_ui/src/widgets/photos_form/view_image_page.dart';
import 'package:flutter/material.dart';

export 'package:image_picker/image_picker.dart';

/// {@template photos_form}
/// Widget that helps to pick images from clipboard, gallery or camera
/// and show them in a horizontal list.
/// {@endtemplate}
class PhotosForm extends StatefulWidget {
  /// {@macro photos_form}
  const PhotosForm({
    required this.onImageListChanged,
    this.images,
    super.key,
  });

  /// List of images to show in the form.
  ///
  /// If null, no images are shown.
  final List<XFile>? images;

  /// Callback that is called when the list of images changes.
  /// ie, when an image is added or removed.
  final void Function(List<XFile> image) onImageListChanged;

  @override
  State<PhotosForm> createState() => _PhotosFormState();
}

class _PhotosFormState extends State<PhotosForm> {
  // XFile? _image;

  // List<XFile> images = [];

  final ImagePicker picker = ImagePicker();

  bool _isSelecting = false;

  // @override
  // void initState() {
  //   super.initState();
  //   images = List<XFile>.from(widget.images ?? []);
  // }

  // static const _dialogRouteName = 'PhotosFormDialog';

  Widget _showDialog(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        // height:  350,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (!Platform.isAndroid) ...[
              //   _PasteAreaWidget(
              //     onImagePasted: (image) {
              //       setState(() {
              //         images.add(image);
              //         widget.onImageListChanged(images);
              //       });
              //     },
              //   ),
              //   const SizedBox(height: 16),
              // ],
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.filter_rounded),
                    title: Text(
                      'Select from gallery',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      // textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      await _pickImage(context, ImageSource.gallery);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () async {
                      await _pickImage(context, ImageSource.camera);
                    },
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      size: 26,
                    ),
                    title: Text(
                      'Take a photo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            // color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    setState(() {
      _isSelecting = true;
    });
    final navigator = Navigator.of(context)..pop();
    final pickedImageXFile = await picker.pickImage(
      source: source,
    );
    setState(() {
      _isSelecting = false;
    });
    if (pickedImageXFile == null) {
      return;
    }

    print(pickedImageXFile.path);

    // final file = File(image.path);

    // final selectedImageFile =
    await navigator
        .push(
      ViewImagePage.route(image: pickedImageXFile),
    )
        .then((value) async {
      if (value != null) {
        final images = List<XFile>.from(widget.images ?? [])..add(value);

        widget.onImageListChanged(images);
        setState(() {
          // images.add(XFile(value!.path));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._getImagePreviewList(height),
        InkWell(
          onTap: () async {
            // await showDialog<void>(
            //   context: context,
            //   useRootNavigator: false,
            //   routeSettings: const RouteSettings(name: _dialogRouteName),
            //   builder: _showDialog,
            // );
            await showModalBottomSheet<void>(
              context: context,
              builder: _showDialog,
            );
          },
          child: SizedBox(
            height: height,
            width: height,
            child: AddPhotoButton(
              isLoading: _isSelecting,
            ),
          ),
        ),
      ],
    );
  }

  Iterable<Widget> _getImagePreviewList(double height) {
    if (widget.images?.isEmpty ?? true) {
      return [];
    } else {
      return widget.images!.indexed.map<Widget>(
        (indexAndImage) => SizedBox(
          height: height,
          width: height,
          child: ImageWidget(
            image: indexAndImage.$2,
            onImageChanged: (XFile? image) {
              setState(() {
                if (image == null) {
                  final images = List<XFile>.from(widget.images ?? [])
                    ..removeAt(indexAndImage.$1);
                  widget.onImageListChanged(images);
                } else {
                  // images
                  //   ..removeAt(indexAndImage.$1)
                  //   ..insert(indexAndImage.$1, image);
                  final images = List<XFile>.from(widget.images ?? []);
                  images[indexAndImage.$1] = image;
                  widget.onImageListChanged(images);
                }
                // images.remove(image);
                // widget.onImageListChanged(images);
              });
            },
          ),
        ),
      );
    }
  }
}
