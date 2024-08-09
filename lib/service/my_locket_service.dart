import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

class MyLocketServices {
  static Dio _dio = Dio();
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

      var url =
          "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCQngaaXQIfJaH0aS2l7REgIjD7nL431So";
      var headers = {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en",
        "baggage":
            "sentry-environment=production,sentry-public_key=78fa64317f434fd89d9cc728dd168f50,sentry-release=com.locket.Locket@1.82.0+3,sentry-trace_id=90310ccc8ddd4d059b83321054b6245b",
        "Connection": "keep-alive",
        "Content-Length": "117",
        "Content-Type": "application/json",
        "Host": "www.googleapis.com",
        "sentry-trace": "90310ccc8ddd4d059b83321054b6245b-3a4920b34e94401d-0",
        "User-Agent": "FirebaseAuth.iOS/10.23.1 com.locket.Locket/1.82.0 iPhone/18.0 hw/iPhone12_1",
        "X-Client-Version": "iOS/FirebaseSDK/10.23.1/FirebaseCore-iOS",
        "X-Firebase-AppCheck":
            "eyJraWQiOiJNbjVDS1EiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxOjY0MTAyOTA3NjA4Mzppb3M6Y2M4ZWI0NjI5MGQ2OWIyMzRmYTYwNiIsImF1ZCI6WyJwcm9qZWN0c1wvNjQxMDI5MDc2MDgzIiwicHJvamVjdHNcL2xvY2tldC00MjUyYSJdLCJwcm92aWRlciI6ImRldmljZV9jaGVja19kZXZpY2VfaWRlbnRpZmljYXRpb24iLCJpc3MiOiJodHRwczpcL1wvZmlyZWJhc2VhcHBjaGVjay5nb29nbGVhcGlzLmNvbVwvNjQxMDI5MDc2MDgzIiwiZXhwIjoxNzIyMTY3ODk4LCJpYXQiOjE3MjIxNjQyOTgsImp0aSI6ImlHUGlsT1dDZGg4Mll3UTJXRC1neEpXeWY5TU9RRFhHcU5OR3AzTjFmRGcifQ.lqTOJfdoYLpZwYeeXtRliCdkVT7HMd7_Lj-d44BNTGuxSYPIa9yVAR4upu3vbZSh9mVHYS8kJGYtMqjP-L6YXsk_qsV_gzKC2IhVAV6KbPDRHdevMfBC6fRiOSVn7vt749GVFdZqAuDCXhCILsaMhvgDBgZoDilgAPtpNwyjz-VtRB7OdOUbuKTCqdoSOX0SJWVUMyuI8nH0-unY--YRctunK8JHZDxBaM_ahVggYPWBCpzxq9Yeq8VSPhadG_tGNaADStYPaeeUkZ7DajwWqH5ze6ESpuFNgAigwPxCM735_ZiPeD7zHYwppQA9uqTWszK9v9OvWtFCsgCEe22O8awbNbuEBTKJpDQ8xvZe8iEYyhfUPncER3S-b1CmuXR7tFCdTgQe5j7NGWjFvN_CnL7D2nudLwxWlpqwASCHvHyi8HBaJ5GpgriTLXAAinY48RukRDBi9HwEzpRecELX05KTD2lTOfQCjKyGpfG2VUHP5Xm36YbA3iqTDoDXWMvV",
        "X-Firebase-GMPID": "1:641029076083:ios:cc8eb46290d69b234fa606",
        "X-Ios-Bundle-Identifier": "com.locket.Locket"
      };

      Response response = await _dio.post(
        url,
        data: json.encode(requestData),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
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

  // todo: split this method to uploadToFireStorage and postToLocket
  static Future<void> uploadImageV2(File image, String caption) async {
    try {
      // Bước 1: Tạo tên file ảnh và lấy kích thước file
      String nameImg = "${DateTime.now().millisecondsSinceEpoch}_vtd182.webp";
      int imageSize = await image.length();

      print(_idToken);
      print(idUser);
      print(imageSize);
      // change size to mb
      print(imageSize / pow(2, 20));
      // Bước 2: Gửi yêu cầu để bắt đầu quá trình upload ảnh lên Firebase Storage
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
            return status! < 500; // Chấp nhận mọi response dưới 500
          },
        ),
      );
      print(response);
      print("Start upload");

      // Bước 3: Upload file ảnh
      String uploadUrl = response.headers.value('X-Goog-Upload-URL')!;
      var uploadHeaders = {
        'content-type': 'application/octet-stream',
        'x-goog-upload-protocol': 'resumable',
        'x-goog-upload-offset': '0',
        'x-goog-upload-command': 'upload, finalize',
        'upload-incomplete': '?0',
        'upload-draft-interop-version': '3',
        'user-agent': 'com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3 (GTMSUF/1)'
      };
      var imageBytes = await image.readAsBytes();

      try {
        var uploadResponse = await _dio.put(
          uploadUrl,
          data: imageBytes,
          options: Options(
            headers: uploadHeaders,
            validateStatus: (status) {
              return status! < 500; // Chấp nhận mọi response dưới 500
            },
          ),
        );
        print(uploadResponse);
      } catch (err) {
        print("Error when update: $err");
      }

      print("Upload done");

      // Bước 4: Lấy download token từ Firebase Storage
      var getUrl =
          'https://firebasestorage.googleapis.com/v0/b/locket-img/o/users%2F$userId%2Fmoments%2Fthumbnails%2F$nameImg';
      var getHeaders = {'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer $_idToken'};
      response = await _dio.get(getUrl, options: Options(headers: getHeaders));
      String downloadToken = response.data['downloadTokens'];

      // Bước 5: Đăng ảnh lên Locket với URL đã được tạo
      String thumbnailUrl = "$getUrl?alt=media&token=$downloadToken";
      print("UrlDownload: $thumbnailUrl");

      var postHeaders = {'content-type': 'application/json', 'authorization': 'Bearer $_idToken'};
      var postData = json.encode({
        "data": {"thumbnail_url": thumbnailUrl, "caption": caption, "sent_to_all": true}
      });
      response = await _dio.post("https://api.locketcamera.com/postMomentV2",
          data: postData, options: Options(headers: postHeaders));

      _postImageController.sink.add(response.statusCode == 200);
      _uploadImageController.sink.add({"url": downloadToken, "success": true});
    } catch (error) {
      print("Error uploading image: $error");
      _postImageController.sink.add(false);
      _uploadImageController.sink.add({"url": "Lỗi!!!", "success": false});
    }
  }
  //
  // static Future<void> logout() async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //   } catch (error) {
  //     print("already logged out");
  //   }
  // }
  //
  // static Future<void> uploadImage(File image, String userId) async {
  //   try {
  //     String uid = "${DateTime.now().millisecondsSinceEpoch}vtd1823";
  //     print(uid);
  //     String fileName = "$uid.webp";
  //     Reference ref = FirebaseStorage.instance.ref().child("users/$userId/moments/thumbnails/$fileName");
  //     UploadTask uploadTask = ref.putFile(image, SettableMetadata(contentType: 'image/webp'));
  //
  //     print(Firebase.app().options.storageBucket);
  //     print(ref.fullPath);
  //
  //     await uploadTask.whenComplete(() async {
  //       try {
  //         String downloadURL = await ref.getDownloadURL();
  //         _uploadImageController.sink.add({"url": downloadURL, "success": true});
  //       } catch (error) {
  //         print("Err: Fail to get download url: $error");
  //         _uploadImageController.sink.add({"url": "Lỗi!!!", "success": false});
  //       }
  //     });
  //   } catch (error) {
  //     print("Err: Failed to upload image $error");
  //     _uploadImageController.sink.add({"url": "Lỗi!!!", "success": false});
  //   }
  // }
  //
  // static Future<void> uploadVideo(File video, File thumbnail, String userId) async {
  //   String uid = DateTime.now().millisecondsSinceEpoch.toString();
  //   String videoFileName = "$uid.mp4";
  //
  //   // Upload thumbnail first
  //   uploadImage(thumbnail, userId).then((_) {
  //     _uploadImageController.stream.listen((imageResult) async {
  //       if (imageResult['success']) {
  //         try {
  //           Reference ref = FirebaseStorage.instance.ref().child("users/$userId/moments/videos/$videoFileName");
  //           UploadTask uploadTask = ref.putFile(video, SettableMetadata(contentType: 'video/mp4'));
  //
  //           await uploadTask.whenComplete(() async {
  //             String downloadURL = await ref.getDownloadURL();
  //             _uploadVideoController.sink
  //                 .add({"videoUrl": downloadURL, "thumbUrl": imageResult['url'], "success": true});
  //           });
  //         } catch (error) {
  //           print("Err: Failed to upload video $error");
  //           _uploadVideoController.sink.add({"videoUrl": "", "thumbUrl": "", "success": false});
  //         }
  //       } else {
  //         _uploadVideoController.sink.add({"videoUrl": "", "thumbUrl": "", "success": false});
  //       }
  //     });
  //   });
  // }

  static Future<void> postImage(String thumbnailUrl, String caption) async {
    print("Thumbnail URL: $thumbnailUrl, Caption: $caption");
    try {
      Map<String, dynamic> req = {
        "data": {
          "thumbnail_url": thumbnailUrl,
          "sent_to_all": true,
          "migration": {"database": "locket"},
        }
      };
      var url = 'https://api.locketcamera.com/postMomentV2';

      print("Request payload: ${json.encode(req)}");

      Response response = await _dio.post(
        url,
        data: json.encode(req),
        options: Options(
          headers: {
            "content-type": "application/json",
            "Authorization": "Bearer ${MyLocketServices.idToken}",
            "accept": "*/*",
            "accept-language": "vi-VN,vi;q=0.9",
            "user-agent": "com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3"
          },
        ),
      );
      print(response);
      _postImageController.sink.add(response.statusCode == 200);
    } catch (error) {
      print("Error when posting image: ${error.toString()}");
      if (error is DioError) {
        print("Dio error response data: ${error.response?.data}");
      }
      _postImageController.sink.add(false);
    }
  }

  static Future<void> postVideo(String videoUrl, String thumbnailUrl, String caption) async {
    try {
      Map<String, dynamic> req = {"video_url": videoUrl, "thumbnail_url": thumbnailUrl, "caption": caption};
      var url = 'https://api.locketcamera.com/postMomentV2';

      Response response = await _dio.post(
        url,
        data: json.encode(req),
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      _postVideoController.sink.add(response.statusCode == 200);
    } catch (error) {
      print(error.toString());
      _postVideoController.sink.add(false);
    }
  }
}
