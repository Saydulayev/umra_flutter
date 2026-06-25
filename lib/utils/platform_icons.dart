import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-adaptive icons: CupertinoIcons on iOS, Material Icons on Android.
class PlatformIcons {
  static bool get _isIOS => Platform.isIOS;

  static IconData get settings =>
      _isIOS ? CupertinoIcons.settings : Icons.settings_outlined;
  static IconData get clock =>
      _isIOS ? CupertinoIcons.clock : Icons.access_time_rounded;
  // RTL-мирроринг (для арабской локали):
  // • Icons.chevron_right (Material) и CupertinoIcons.back — уже имеют
  //   matchTextDirection: true в исходниках Flutter, зеркалятся сами.
  // • CupertinoIcons.chevron_right его НЕ имеет, поэтому для iOS используем
  //   const-копию с matchTextDirection: true. Именно const — иначе runtime
  //   IconData ломает tree-shaker в release-сборке (--tree-shake-icons).
  static const IconData _chevronRightCupertinoRtl = IconData(
    0xf3d3, // = CupertinoIcons.chevron_right
    fontFamily: CupertinoIcons.iconFont,
    fontPackage: CupertinoIcons.iconFontPackage,
    matchTextDirection: true,
  );
  static IconData get chevronRight =>
      _isIOS ? _chevronRightCupertinoRtl : Icons.chevron_right;
  static IconData get info =>
      _isIOS ? CupertinoIcons.info : Icons.info_outline_rounded;
  static IconData get arrowBack =>
      _isIOS ? CupertinoIcons.back : Icons.arrow_back;
  static IconData get refresh =>
      _isIOS ? CupertinoIcons.arrow_clockwise : Icons.refresh;
  static IconData get rotateRight =>
      _isIOS ? CupertinoIcons.arrow_clockwise : Icons.rotate_right;
  static IconData get check => _isIOS ? CupertinoIcons.checkmark : Icons.check;
  static IconData get checkCircle =>
      _isIOS ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle;
  static IconData get addCircle =>
      _isIOS ? CupertinoIcons.plus_circle_fill : Icons.add_circle;
  static IconData get cancel =>
      _isIOS ? CupertinoIcons.xmark_circle_fill : Icons.cancel;
  static IconData get close => _isIOS ? CupertinoIcons.xmark : Icons.close;
  static IconData get repeat => _isIOS ? CupertinoIcons.repeat : Icons.repeat;
  static IconData get pause => _isIOS ? CupertinoIcons.pause_fill : Icons.pause;
  static IconData get playArrow =>
      _isIOS ? CupertinoIcons.play_fill : Icons.play_arrow;
  static IconData get errorOutline =>
      _isIOS ? CupertinoIcons.exclamationmark_circle : Icons.error_outline;
  static IconData get chevronDown =>
      _isIOS ? CupertinoIcons.chevron_down : Icons.keyboard_arrow_down;
  static IconData get textFormat =>
      _isIOS ? CupertinoIcons.textformat : Icons.text_fields;
  static IconData get notifications =>
      _isIOS ? CupertinoIcons.bell : Icons.notifications_outlined;
  static IconData get feedback =>
      _isIOS ? CupertinoIcons.chat_bubble_text : Icons.feedback_outlined;
  static IconData get starOutline =>
      _isIOS ? CupertinoIcons.star : Icons.star_outline;
  static IconData get language =>
      _isIOS ? CupertinoIcons.globe : Icons.language;
  static IconData get palette =>
      _isIOS ? CupertinoIcons.paintbrush : Icons.palette_outlined;
  static IconData get donation =>
      _isIOS ? CupertinoIcons.heart : Icons.paid_outlined;
  static IconData get copy => _isIOS ? CupertinoIcons.doc_on_doc : Icons.copy;
  static IconData get walk =>
      _isIOS ? CupertinoIcons.arrow_right_circle : Icons.directions_walk;
  static IconData get expandMore =>
      _isIOS ? CupertinoIcons.chevron_down : Icons.expand_more;
  static IconData get book =>
      _isIOS ? CupertinoIcons.book : Icons.auto_stories_outlined;

  // ─── Bottom tab bar: outline (inactive) / filled (active) pairs ─────────────
  static IconData get home =>
      _isIOS ? CupertinoIcons.house : Icons.home_outlined;
  static IconData get homeFill =>
      _isIOS ? CupertinoIcons.house_fill : Icons.home;
  static IconData get location =>
      _isIOS ? CupertinoIcons.location : Icons.place_outlined;
  static IconData get locationFill =>
      _isIOS ? CupertinoIcons.location_solid : Icons.place;
  static IconData get bookFill =>
      _isIOS ? CupertinoIcons.book_fill : Icons.auto_stories;
  static IconData get clockFill =>
      _isIOS ? CupertinoIcons.clock_fill : Icons.access_time_filled;
}
