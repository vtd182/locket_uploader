import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:locket_uploader/constants/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyLocketServices {
  static final Dio _dio = Dio();
  static final _uploadImageController = BehaviorSubject<Map<String, dynamic>>();
  static final _uploadVideoController = BehaviorSubject<Map<String, dynamic>>();
  static final _postImageController = BehaviorSubject<bool>();
  static final _postVideoController = BehaviorSubject<bool>();

  static Stream<Map<String, dynamic>> get uploadImageStream => _uploadImageController.stream;
  static Stream<Map<String, dynamic>> get uploadVideoStream => _uploadVideoController.stream;
  static Stream<bool> get postImageStream => _postImageController.stream;
  static Stream<bool> get postVideoStream => _postVideoController.stream;

  static String? idUser;
  static String? get userId => idUser;

  static String? _idToken;
  static String? get idToken => _idToken;

  static Future<String?> loginV2(String email, String password) async {
    try {
      final requestData = {
        "email": email,
        "password": password,
        "clientType": "CLIENT_TYPE_IOS",
        "returnSecureToken": true
      };

      Response response = await _dio.post(
        Constants.loginUrl,
        data: json.encode(requestData),
        options: Options(headers: Constants.loginHeader),
      );

      if (response.statusCode == 200) {
        print(response);
        _idToken = response.data['idToken'];
        idUser = response.data['localId'];
        return _idToken;
      } else {
        print("Error: ${response.statusMessage}");
        return null;
      }
    } catch (error) {
      print("Error in loginV2: ${error.toString()}");
      return null;
    }
  }

  static Future<void> uploadImage(File image) async {
    try {
      var data = await image.readAsBytes();
      await _uploadImageToFireStorage(data);
    } catch (error) {
      print(error.toString());
    }
  }

  static Future<void> _uploadImageToFireStorage(Uint8List image) async {
    try {
      String nameImg = "${DateTime.now().millisecondsSinceEpoch}_vtd182.webp";
      int imageSize = image.lengthInBytes;
      // change size to mb
      print(imageSize / pow(2, 20));

      String url =
          'https://firebasestorage.googleapis.com/v0/b/locket-img/o/users%2F$idUser%2Fmoments%2Fthumbnails%2F$nameImg?uploadType=resumable&name=users%2F$userId%2Fmoments%2Fthumbnails%2F$nameImg';
      print(url);
      var headers = {
        'content-type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer $_idToken',
        'x-goog-upload-protocol': 'resumable',
        'accept': '*/*',
        'x-goog-upload-command': 'start',
        'x-goog-upload-content-length': imageSize.toString(),
        'accept-language': 'vi-VN,vi;q=0.9',
        'x-firebase-storage-version': 'ios/10.13.0',
        'user-agent': 'com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3 (GTMSUF/1)',
        'x-goog-upload-content-type': 'image/webp',
        'x-firebase-gmpid': '1:641029076083:ios:cc8eb46290d69b234fa609',
      };

      var data = json.encode({
        "name": "users/$userId/moments/thumbnails/$nameImg",
        "contentType": "image/*",
        "bucket": "",
        "metadata": {"creator": userId, "visibility": "private"}
      });

      Response response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      String uploadUrl = response.headers.value('X-Goog-Upload-URL')!;

      try {
        var uploadResponse = await _dio.put(
          uploadUrl,
          data: image,
          options: Options(
            headers: Constants.uploaderHeader,
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );
        print(uploadResponse);
      } catch (err) {
        print("Error when update: $err");
        _uploadImageController.sink.add({"url": "ERRRR!!!", "success": false});
      }

      print("Upload done");

      var getUrl =
          'https://firebasestorage.googleapis.com/v0/b/locket-img/o/users%2F$userId%2Fmoments%2Fthumbnails%2F$nameImg';
      var getHeaders = {'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer $_idToken'};
      response = await _dio.get(getUrl, options: Options(headers: getHeaders));
      String downloadToken = response.data['downloadTokens'];

      String thumbnailUrl = "$getUrl?alt=media&token=$downloadToken";
      print("UrlDownload: $thumbnailUrl");
      _uploadImageController.sink.add({"url": thumbnailUrl, "success": true});
    } catch (error) {
      print("Error uploading image: $error");
      _postImageController.sink.add(false);
      _uploadImageController.sink.add({"url": "ERRRR!!!", "success": false});
    }
  }

  static Future<void> postImageV2(String thumbnailUrl, String caption) async {
    print("Thumbnail URL: $thumbnailUrl, Caption: $caption");
    try {
      var postHeaders = {'content-type': 'application/json', 'authorization': 'Bearer $_idToken'};
      var postData = json.encode({
        "data": {"thumbnail_url": thumbnailUrl, "caption": caption, "sent_to_all": true}
      });
      var response = await _dio.post("https://api.locketcamera.com/postMomentV2",
          data: postData, options: Options(headers: postHeaders));
      _postImageController.sink.add(response.statusCode == 200);
    } catch (error) {
      print("Error when posting image: ${error.toString()}");
      if (error is DioException) {
        print("Dio error response data: ${error.response?.data}");
      }
      _postImageController.sink.add(false);
    }
  }

  static Future<void> uploadVideoV2(File video, File thumbnail) async {
    await uploadThumbnailFromVideo(video.path).then((_) {
      _uploadImageController.stream.listen((imageResult) async {
        if (imageResult['success']) {
          try {
            String nameVideo = "${DateTime.now().millisecondsSinceEpoch}_vtd182.mp4";
            int videoSize = await video.length();

            String url =
                'https://firebasestorage.googleapis.com/v0/b/locket-video/o/users%2F$idUser%2Fmoments%2Fvideos%2F$nameVideo?uploadType=resumable&name=users%2F$userId%2Fmoments%2Fthumbnails%2F$nameVideo';
            print(url);
            var headers = {
              'content-type': 'application/json; charset=UTF-8',
              'authorization': 'Bearer $_idToken',
              'x-goog-upload-protocol': 'resumable',
              'accept': '*/*',
              'x-goog-upload-command': 'start',
              'x-goog-upload-content-length': videoSize.toString(),
              'accept-language': 'vi-VN,vi;q=0.9',
              'x-firebase-storage-version': 'ios/10.13.0',
              'user-agent': 'com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3 (GTMSUF/1)',
              'x-goog-upload-content-type': 'video/mp4',
              'x-firebase-gmpid': '1:641029076083:ios:cc8eb46290d69b234fa609',
            };

            var data = json.encode({
              "name": "users/$userId/moments/videos/$nameVideo",
              "contentType": "image/*",
              "bucket": "",
              "metadata": {"creator": userId, "visibility": "private"}
            });

            Response response = await _dio.post(
              url,
              data: data,
              options: Options(
                headers: headers,
                validateStatus: (status) {
                  return status! < 500;
                },
              ),
            );

            String uploadUrl = response.headers.value('X-Goog-Upload-URL')!;
            var imageBytes = await video.readAsBytes();

            try {
              var uploadResponse = await _dio.put(
                uploadUrl,
                data: imageBytes,
                options: Options(
                  headers: Constants.uploaderHeader,
                  validateStatus: (status) {
                    return status! < 500;
                  },
                ),
              );
              print(uploadResponse);
            } catch (err) {
              print("Error when update: $err");
              _uploadImageController.sink.add({"url": "ERRRR!!!", "success": false});
            }

            var getUrl =
                'https://firebasestorage.googleapis.com/v0/b/locket-video/o/users%2F$userId%2Fmoments%2Fvideos%2F$nameVideo';
            var getHeaders = {'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer $_idToken'};
            response = await _dio.get(getUrl, options: Options(headers: getHeaders));
            String downloadToken = response.data['downloadTokens'];
            String downloadURL = "$getUrl?alt=media&token=$downloadToken";

            _uploadVideoController.sink.add({"videoUrl": downloadURL, "thumbUrl": imageResult['url'], "success": true});
          } catch (err) {
            print("Err: Failed to upload video $err");
            _uploadVideoController.sink.add({"videoUrl": "", "thumbUrl": "", "success": false});
          }
        } else {
          _uploadVideoController.sink.add({"videoUrl": "", "thumbUrl": "", "success": false});
        }
      });
    });
  }

  static Future<void> uploadThumbnailFromVideo(String videoPath) async {
    try {
      var thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );

      if (thumbnailBytes == null) {
        throw Exception("Unable to create thumbnail");
      }
      _uploadImageToFireStorage(thumbnailBytes);
    } catch (error) {
      print(error.toString());
    }
  }

  // todo: finding api for post video
  static Future<void> postVideo(String videoUrl, String thumbnailUrl, String caption) async {
    try {
      var postHeaders = {'content-type': 'application/json', 'authorization': 'Bearer $_idToken'};
      var postData = json.encode({
        "data": {"videoUrl": videoUrl, "thumbUrl": thumbnailUrl, "caption": caption}
      });
      var response = await _dio.post("https://api.locketcamera.com/postMomentV2",
          data: postData, options: Options(headers: postHeaders));

      _postVideoController.sink.add(response.statusCode == 200);
      print("VIDEOOOOOOO: $response");
    } catch (error) {
      print(error.toString());
      _postVideoController.sink.add(false);
    }
  }
}
