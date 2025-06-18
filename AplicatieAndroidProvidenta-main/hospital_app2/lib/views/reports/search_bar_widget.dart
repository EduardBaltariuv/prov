import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
  controller: controller, // Add this line
  elevation: MaterialStateProperty.all(0.0),
  backgroundColor: MaterialStateProperty.all(const Color(0xFFF5F5F5)),
  padding: const MaterialStatePropertyAll<EdgeInsets>(
    EdgeInsets.symmetric(horizontal: 16.0),
  ),
          onTap: () {
            // controller.openView();
          },
          onChanged: (_) {
            // controller.openView();
          },
          leading: const Icon(
            Icons.search,
            size: 30.0,
            color: Color.fromARGB(255, 179, 179, 179),
          ),
          trailing: [
            const Icon(
              Icons.filter_alt_outlined,
              size: 30.0,
              color: Color.fromARGB(255, 0, 0, 0),
            )
          ],
          hintText: 'Cauta un raport',
          hintStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Color.fromARGB(255, 179, 179, 179),
            ),
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
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