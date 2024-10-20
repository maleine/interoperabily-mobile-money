import 'package:flutter/material.dart';
import 'package:interoperabilite/widgets/app_TextStyle.dart';
import 'package:interoperabilite/widgets/colors.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final Color? color;
  final dynamic imgPath;
  final VoidCallback onPressed;
  const CommonButton({
    super.key,
    this.imgPath,
    required this.title,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 50),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (imgPath != null)
              ClipOval(
                child: Image.asset(
                  imgPath!,
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
                ),
              ),
            Text(
              title,
              style: appTextStyle(
                ColorTheme.blackColor,
                FontWeight.bold,
                16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
