import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          elevation: MaterialStateProperty.all(2.0),
          backgroundColor: MaterialStateProperty.all(AppTheme.surfaceWhite),
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            // controller.openView();
          },
          onChanged: (_) {
            // controller.openView();
          },
          leading: Icon(
            Icons.search_rounded,
            size: 24.0,
            color: AppTheme.steelGray,
          ),
          trailing: [
            Icon(
              Icons.tune_rounded,
              size: 24.0,
              color: AppTheme.primaryBlue,
            )
          ],
          hintText: 'Caută un raport...',
          hintStyle: MaterialStateProperty.all(
            TextStyle(
              color: AppTheme.steelGray.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: AppTheme.darkGray,
              fontSize: 16,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: AppTheme.dividerColor,
                width: 1,
              ),
            ),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            title: Text(item),
          );
        });
      },
    );
  }
}