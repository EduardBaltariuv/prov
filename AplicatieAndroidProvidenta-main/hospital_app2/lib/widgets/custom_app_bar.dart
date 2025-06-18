import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/navigation_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool useNavigator;
  final bool enableBackButton;
  final PageKey navigationIndex;
  
  const CustomAppBar({
    super.key,
    required this.title,
    required this.useNavigator, 
    required this.navigationIndex,
    this.enableBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final navigationVM = Provider.of<NavigationViewModel>(
      context,
      listen: false,
    );

    return AppBar(
      scrolledUnderElevation: 0.0, // Prevents color change when scrolling
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      leading: enableBackButton ? IconButton(
        padding: const EdgeInsets.only(left: 16),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
        onPressed: () {
          if (useNavigator) {
            Navigator.pop(context); // Go back to the previous screen
          } else {
            navigationVM.navigateTo(navigationIndex);
          }
        },
      ) : null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        )
    
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
