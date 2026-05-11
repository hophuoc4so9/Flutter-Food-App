import 'package:flutter/material.dart';

/// Custom AppBar widget với cấu trúc thống nhất
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFFD32F2F),
    this.elevation = 0.5,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.titleStyle,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      iconTheme: IconThemeData(color: textColor),
      leading: leading ?? (Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar cho trang chính (Dashboard)
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int cartCount;
  final VoidCallback? onCartPressed;
  final VoidCallback? onLogoutPressed;
  final Widget? leading;

  const DashboardAppBar({
    Key? key,
    required this.title,
    this.cartCount = 0,
    this.onCartPressed,
    this.onLogoutPressed,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: leading ?? Icon(Icons.menu, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        // Cart Button
        GestureDetector(
          onTap: onCartPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  top: 8,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$cartCount",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 8),
        // Logout Button
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: onLogoutPressed,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar cho trang thanh toán
class PaymentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color? titleColor;
  final Color backgroundColor;

  const PaymentAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.titleColor,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: titleColor ?? Colors.white,
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar cho trang danh sách (Menu)
class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String categoryName;
  final VoidCallback? onBackPressed;

  const MenuAppBar({
    Key? key,
    required this.categoryName,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "Menu: $categoryName",
        style: const TextStyle(
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 1,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar cho trang chi tiết sản phẩm
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const DetailAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
