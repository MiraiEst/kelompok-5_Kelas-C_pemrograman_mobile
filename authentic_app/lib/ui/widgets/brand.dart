import 'package:flutter/material.dart';

import '../theme.dart';

/// Authentic logo. [full] = arrows + wordmark, otherwise only the arrows icon.
class AuthenticLogo extends StatelessWidget {
  const AuthenticLogo.full({super.key, this.height = 36}) : _full = true;
  const AuthenticLogo.icon({super.key, this.height = 36}) : _full = false;

  final double height;
  final bool _full;

  @override
  Widget build(BuildContext context) => Image.asset(
    _full ? 'assets/images/logo_full.png' : 'assets/images/logo_icon.png',
    height: height,
    fit: BoxFit.contain,
    semanticLabel: 'Authentic',
  );
}

/// White panel with a thick black outline and large rounded corners
/// (the login card in the design). Centred, max 420 px wide.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.ink, width: 3),
            borderRadius: BorderRadius.circular(AppRadius.panel),
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Small bold link text used under fields ("Lupa password?", "Register?").
class SmallLink extends StatelessWidget {
  const SmallLink(this.label, {super.key, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
    ),
  );
}

/// Home top bar: logo icon on the left, round profile avatar on the right,
/// thin black line underneath.
class AuthenticTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthenticTopBar({super.key, this.onAvatarTap});
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 72,
    automaticallyImplyLeading: false,
    titleSpacing: 16,
    title: const AuthenticLogo.icon(height: 40),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Semantics(
          button: true,
          label: 'Profile',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.ink,
              child: Icon(Icons.person, color: AppColors.paper, size: 30),
            ),
          ),
        ),
      ),
    ],
  );
}

class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
}

/// Bottom navigation in the Authentic style: icon + label, the selected tab
/// sits in a black rounded tile with white content. A soft grey fade sits on
/// top of the bar, as in the design.
class AuthenticNavBar extends StatelessWidget {
  const AuthenticNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 20,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.paper, Color(0xFFE4E4E4)],
          ),
        ),
      ),
      Material(
        color: AppColors.paper,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Background and content colours are animated together, so the icon and
    // label never disappear (white on white) while the tile changes.
    return Center(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: selected ? 1 : 0),
            duration: const Duration(milliseconds: 180),
            builder: (context, t, _) {
              final bg = Color.lerp(AppColors.paper, AppColors.ink, t)!;
              final fg = Color.lerp(AppColors.ink, AppColors.paper, t)!;
              Widget icon = Icon(selected ? item.activeIcon : item.icon, color: fg, size: 28);
              if (item.badge > 0) {
                icon = Badge(
                  label: Text('${item.badge}'),
                  backgroundColor: fg,
                  textColor: bg,
                  child: icon,
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fg),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Large page heading used at the top of tabs (e.g. "My activity").
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.ink),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
