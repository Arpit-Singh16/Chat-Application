import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> calling(String number) async {
  final Uri teluri=Uri(scheme: 'tel', path: number);
  if(await canLaunchUrl(teluri)){
    await launchUrl(teluri);
  }
  }

Future<File?> image() async{
  final picker =ImagePicker();

  final XFile? img=await picker.pickImage(source: ImageSource.gallery);
    if(img!=null){
      return File(img.path);
    }
    return null;
}

