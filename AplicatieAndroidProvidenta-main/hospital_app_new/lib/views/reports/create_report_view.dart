import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/image_picker_viewmodel.dart';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'dart:io';


class CreateReportView extends StatefulWidget {
  const CreateReportView({super.key});

  @override
  _CreateReportViewState createState() => _CreateReportViewState();
}

class _CreateReportViewState extends State<CreateReportView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<bool> submitReport(
    String title,
    String description,
    String category,
    String location,
    List<XFile> images,
  ) async {
    var submitSuccess = false;
    final reportVM = Provider.of<ReportViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    // Check if username is available
    if (authVM.username == null || authVM.username!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eroare: utilizatorul nu este autentificat')),
        );
      }
      return false;
    }

    final result = await reportVM.createReport(
      title: title,
      description: description,
      category: category,
      location: location,
      images: images,
      username: authVM.username!,
    );

    switch (result) {
      case Success():
        submitSuccess = true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Raportul a fost creat cu succes!')),
          );
        }
        break;
      case Failure(:final message):
        if (context.mounted) {
          final friendlyMessage = mapErrorToMessage(message);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyMessage)));
        }
        break;
    }
    return submitSuccess;
  }

  String mapErrorToMessage(String error) {
    print('Mapping error: $error'); // Debug log
    
    if (error.contains('SocketException') || error.contains('No address associated with hostname')) {
      return 'Raportul nu a fost creat, verificati conexiunea la internet.';
    } else if (error.contains('USER_NOT_AUTHENTICATED') || error.contains('INVALID_USER')) {
      return 'Eroare: utilizatorul nu este autentificat. Va rugam sa va reconectati.';
    } else if (error.contains('MISSING_FIELDS') || error.contains('MISSING_REQUIRED_FIELDS') || error.contains('400')) {
      return 'Completati toate campurile obligatorii.';
    } else if (error.contains('timeout') || error.contains('TimeoutException')) {
      return 'Cererea a expirat. Incercati mai tarziu.';
    } else if (error.contains('SERVER_ERROR') || error.contains('500')) {
      return 'Eroare server. Incercati din nou.';
    } else if (error.contains('REQUEST_TOO_LARGE') || error.contains('413')) {
      return 'Imaginile sunt prea mari. Reduceti marimea imaginilor.';
    } else if (error.contains('Failed to submit report')) {
      // Extract the actual error from the nested exception
      final match = RegExp(r'Failed to submit report: (.+)').firstMatch(error);
      if (match != null) {
        return mapErrorToMessage(match.group(1)!); // Recursively map the inner error
      }
    }
    
    // If no specific error pattern matches, show generic message
    return 'A aparut o eroare. Incercati din nou.';
  }

  @override
  Widget build(BuildContext context) {
    final navigationVm = Provider.of<NavigationViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: CustomAppBar(
        title: "Crează raport",
        navigationIndex: PageKey.reports,
        useNavigator: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                "TITLUL*",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Adauga un titlu",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 179, 179, 179),
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 0.1,
              color: Color.fromARGB(255, 0, 0, 0),
              indent: 0,
            ),
            const SizedBox(height: 16),
            const AddCategorySection(),
            const SizedBox(height: 16),
            const Divider(
              thickness: 0.1,
              color: Color.fromARGB(255, 0, 0, 0),
              indent: 0,
            ),
            const AddLocationSection(),
            const Divider(
              thickness: 0.1,
              color: Color.fromARGB(255, 0, 0, 0),
              indent: 0,
            ),
            const SizedBox(height: 16),
            const AddPhotosSection(),
            const SizedBox(height: 16),
            const Divider(
              thickness: 0.1,
              color: Color.fromARGB(255, 0, 0, 0),
              indent: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: const Text(
                "DESCRIERE*",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextField(
                controller: descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Adauga o descriere",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 179, 179, 179),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
  var submitSuccess = false;
  final localContext = context;
  final images = Provider.of<ImagePickerViewModel>(
    localContext,
    listen: false,
  ).images;
  
  submitSuccess = await submitReport(
    titleController.text,
    descriptionController.text,
    Provider.of<ReportViewModel>(context, listen: false).selectedCategory ?? 'Altele',
    Provider.of<ReportViewModel>(context, listen: false).selectedLocation ?? '',
    images,
    
  );
  
  if (submitSuccess && localContext.mounted) {
    // Clear form fields
    
    
    // Reset view models
    Provider.of<ReportViewModel>(localContext, listen: false).resetSelections();
    Provider.of<ImagePickerViewModel>(localContext, listen: false).clearImages();
    titleController.clear();
    descriptionController.clear();
    navigationVm.navigateTo(PageKey.reports);
  }
},
          
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Raport nou",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AddCategorySection extends StatelessWidget {
  const AddCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportVM, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CATEGORIE*",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: DropdownButton<String>(
                  underline: const SizedBox(),
                  iconSize: 0.0,
                  value: reportVM.selectedCategory,
                  hint: const Text(
                    "Selectează o categorie",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      reportVM.setSelectedCategory(newValue);
                    }
                  },
                  items: reportVM.categories.map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddLocationSection extends StatelessWidget {
  const AddLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reportVM = Provider.of<ReportViewModel>(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "LOCATIE*",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: DropdownButton<String>(
              underline: const SizedBox(),
              iconSize: 0.0,
              value: reportVM.selectedLocation,
              hint: const Text(
                "Selectează locația",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  reportVM.setSelectedLocation(newValue);
                }
              },
              items: reportVM.locatii.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPhotosSection extends StatelessWidget {
  const AddPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FOTOGRAFII",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  // Open the camera directly (no gallery)
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    // If a photo is taken, add it to your image list via ImagePickerViewModel
                    final imagePickerVM = Provider.of<ImagePickerViewModel>(context, listen: false);
                    imagePickerVM.addImage(photo);
                  }
                },
                icon: const Icon(Icons.add_a_photo),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preview the selected images
          Consumer<ImagePickerViewModel>(
            builder: (context, imagePickerVM, child) {
              return imagePickerVM.images.isEmpty
                  ? const Text("Nicio fotografie adăugată.")
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: imagePickerVM.images.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(imagePickerVM.images[index].path),
                          fit: BoxFit.cover,
                        );
                      },
                    );
            },
          ),
        ],
      ),
    );
  }
}