import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locket_uploader/bloc/app/app_cubit.dart';
import 'package:locket_uploader/domain/repositories/upload_repository.dart';
import 'package:locket_uploader/models/user_profile.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

import '../bloc/main_screen/main_screen_cubit.dart';
import '../constants/constants.dart';

class MainScreen extends StatelessWidget {
  static const route = '/main';
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final uploadRepository = context.read<UploadRepository>();
        return MainScreenCubit(uploadRepository);
      }, // Khởi tạo MainScreenCubit
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          return MainScreenView(userProfile: appState.userProfile);
        },
      ),
    );
  }
}

class MainScreenView extends StatefulWidget {
  final UserProfile? userProfile;
  const MainScreenView({super.key, required this.userProfile});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  XFile? _mediaFile;
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();
  final BehaviorSubject<bool> _isUploading = BehaviorSubject<bool>.seeded(false);

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    _isUploading.close();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile;
    if (isVideo) {
      pickedFile = await picker.pickVideo(source: source);
    } else {
      pickedFile = await picker.pickImage(source: source);
    }

    if (pickedFile != null) {
      setState(
        () {
          _mediaFile = pickedFile;
          _videoController?.dispose();
          _videoController = null;

          if (isVideo) {
            _videoController = VideoPlayerController.file(File(pickedFile!.path))
              ..initialize().then((_) {
                setState(() {});
                _videoController?.play();
              });
          }
        },
      );
    }
  }

  void _showMediaPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Color(Constants.yellowColor),
                  ),
                  title: Text(
                    'Pick Image',
                    style: TextStyle(
                      color: Color(Constants.yellowColor),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMedia(ImageSource.gallery, isVideo: false);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.videocam,
                    color: Color(Constants.yellowColor),
                  ),
                  title: Text(
                    'Pick Video',
                    style: TextStyle(
                      color: Color(Constants.yellowColor),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMedia(ImageSource.gallery, isVideo: true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOrVideoPreview() {
    return GestureDetector(
      onTap: () => _showMediaPickerBottomSheet(context),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(
            color: Color(Constants.yellowColor),
            width: 2,
          ),
        ),
        child: _mediaFile == null
            ? const Icon(Icons.add, color: Colors.white, size: 50)
            : _mediaFile!.path.endsWith('.mp4') ||
                    _mediaFile!.path.endsWith('.mov') ||
                    _mediaFile!.path.endsWith('.MOV')
                ? _videoController != null && _videoController!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_mediaFile!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
      ),
    );
  }

  void _sendContent() {
    String caption = _captionController.text.trim();
    if (_mediaFile != null) {
      if (_mediaFile!.path.endsWith('.mp4') || _mediaFile!.path.endsWith('.mov') || _mediaFile!.path.endsWith('.MOV')) {
        _isUploading.add(true);
        final res =
            context.read<MainScreenCubit>().postVideoToLocket(widget.userProfile!, File(_mediaFile!.path), caption);
        _isUploading.add(false);
      } else {
        _isUploading.add(true);
        final res =
            context.read<MainScreenCubit>().postImageToLocket(widget.userProfile!, File(_mediaFile!.path), caption);
        _isUploading.add(false);
      }
    } else {
      print('No media selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainScreenCubit, MainScreenState>(
      listener: (context, state) {
        if (state is MainScreenUploading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        } else if (state is MainScreenUploadedSuccess) {
          Navigator.of(context).pop(); // Dismiss loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Uploaded successfully")),
          );
        } else if (state is MainScreenUploadedFailure) {
          Navigator.of(context).pop(); // Dismiss loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${state.error}")),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return widget.userProfile == null
        ? AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  size: 30,
                  Icons.logout_sharp,
                  color: Color(Constants.yellowColor),
                ),
                onPressed: () {
                  print('Logout');
                  context.read<AppCubit>().logout();
                },
              ),
            ],
          )
        : AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  size: 30,
                  Icons.logout_sharp,
                  color: Color(Constants.yellowColor),
                ),
                onPressed: () {
                  print('Logout');
                  context.read<AppCubit>().logout();
                },
              ),
            ],
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(Constants.yellowColor), width: 2),
              ),
              child: ClipOval(
                child: (widget.userProfile?.profilePicture != null || widget.userProfile!.profilePicture.isNotEmpty)
                    ? Image.network(
                        widget.userProfile!.profilePicture,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(Constants.userIcon),
              ),
            ),
            title: Text(
              widget.userProfile?.displayName ?? '',
              style: TextStyle(
                color: Color(Constants.yellowColor),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImageOrVideoPreview(),
          const SizedBox(height: 20),
          _buildCaptionField(),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildCaptionField() {
    return Form(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: _captionController,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(Constants.yellowColor), width: 2.0),
                ),
                hintText: "Enter your caption here",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading.value ? null : _sendContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(Constants.yellowColor),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: StreamBuilder<bool>(
          stream: _isUploading.stream,
          initialData: false,
          builder: (context, snapshot) {
            return snapshot.data!
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    "Send!",
                    style: TextStyle(color: Color(0xff1f1d1a), fontSize: 22, fontWeight: FontWeight.w900),
                  );
          },
        ),
      ),
    );
  }
}
