import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// Circle with the user's photo, or the first letter of their name.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.photoUrl, this.size = 36});
  final String name;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final url = photoUrl;
    return Semantics(
      label: context.l10n.avatarOf(name),
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onInk,
        foregroundImage: (url == null || url.isEmpty) ? null : CachedNetworkImageProvider(url),
        child: Text(
          initial,
          style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
