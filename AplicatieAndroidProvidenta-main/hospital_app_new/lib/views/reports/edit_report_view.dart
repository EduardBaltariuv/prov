import 'package:flutter/material.dart';
import 'package:hospital_app/models/report.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../viewmodels/navigation_viewmodel.dart';

class EditReportView extends StatefulWidget {
  final Report report;

  const EditReportView({super.key, required this.report});

  @override
  State<EditReportView> createState() => _EditReportViewState();
}

class _EditReportViewState extends State<EditReportView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedLocation;
  List<XFile> _newImages = [];
  bool _isSubmitting = false;
  bool _keepExistingImages = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize form with current report data
    _titleController.text = widget.report.title;
    _descriptionController.text = widget.report.description;
    _selectedCategory = widget.report.category;
    _selectedLocation = widget.report.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la selectarea imaginilor: $e')),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vă rugăm să selectați categoria și locația')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final reportVM = Provider.of<ReportViewModel>(context, listen: false);
      final navVM = Provider.of<NavigationViewModel>(context, listen: false);

      final result = await reportVM.updateReport(
        reportId: widget.report.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _selectedLocation!,
        newImages: _newImages.isNotEmpty ? _newImages : null,
        username: authVM.getUsername!,
        keepExistingImages: _keepExistingImages,
      );

      if (mounted) {
        if (result is Success<String>) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.data),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to reports
          navVM.navigateTo(PageKey.reports);
          Navigator.of(context).pop(); // Pop the edit view
        } else if (result is Failure<String>) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare neașteptată: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportVM = Provider.of<ReportViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: "Editează raportul",
        navigationIndex: PageKey.reports,
        useNavigator: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              _buildTextField(
                controller: _titleController,
                label: 'Titlu',
                hint: 'Introduceți titlul raportului',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Titlul este obligatoriu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              _buildTextField(
                controller: _descriptionController,
                label: 'Descriere',
                hint: 'Descrieți problema în detaliu',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrierea este obligatorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              _buildDropdown(
                label: 'Categorie',
                value: _selectedCategory,
                items: reportVM.categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Location dropdown
              _buildDropdown(
                label: 'Locație',
                value: _selectedLocation,
                items: reportVM.locatii,
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Existing images section
              if (widget.report.imagePaths.isNotEmpty) ...[
                _buildSectionHeader('Imaginile existente'),
                const SizedBox(height: 8),
                _buildExistingImagesSection(),
                const SizedBox(height: 16),
              ],

              // New images section
              _buildSectionHeader('Adaugă imagini noi (opțional)'),
              const SizedBox(height: 8),
              _buildNewImagesSection(),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Actualizează raportul',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.lightGray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.charcoal,
      ),
    );
  }

  Widget _buildExistingImagesSection() {
    return Column(
      children: [
        // Toggle for keeping existing images
        Row(
          children: [
            Checkbox(
              value: _keepExistingImages,
              onChanged: (bool? value) {
                setState(() {
                  _keepExistingImages = value ?? true;
                });
              },
              activeColor: AppTheme.primaryBlue,
            ),
            Expanded(
              child: Text(
                'Păstrează imaginile existente',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.charcoal,
                ),
              ),
            ),
          ],
        ),
        
        // Display existing images
        if (_keepExistingImages && widget.report.imagePaths.isNotEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.report.imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.lightGray),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.report.imagePaths[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.lightGray,
                          child: const Icon(Icons.error),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.lightGray,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNewImagesSection() {
    return Column(
      children: [
        // Add images button
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.lightGray.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, 
                  size: 32, 
                  color: AppTheme.steelGray
                ),
                const SizedBox(height: 8),
                Text(
                  'Adaugă imagini noi',
                  style: TextStyle(
                    color: AppTheme.steelGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Display new selected images
        if (_newImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.lightGray),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_newImages[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
