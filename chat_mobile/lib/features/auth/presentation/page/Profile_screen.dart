import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../widget/profile/info_card.dart';
import '../widget/profile/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const LoadMeEvent());
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  context.read<AuthBloc>().add(UpdatePhotoEvent(bytes));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  context.read<AuthBloc>().add(UpdatePhotoEvent(bytes));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editField(
    String title,
    String initialValue,
    Function(String) onSave, {
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          maxLines: title == 'Bio' ? 5 : 1,
          decoration: InputDecoration(
            hintText: 'Enter your $title',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
         ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text(
              'Save', // Updated text
              style: TextStyle(color: Colors.white), // Explicitly set text color
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      onSave(result);
      _showSnackbar('$title updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is MeSuccessState) {
            setState(() {
              user = state.user;
            });
          }
          if (state is MeFailureState) {
            _showSnackbar(state.failure.message);
          } else if (state is UpdateMeState) {
            setState(() {
              user = state.user;
            });
            _showSnackbar('Profile updated successfully');
          }
          else if (state is UpdatePhotoState) {
            setState(() {
              user = state.user;
            });
            _showSnackbar('Profile Photo updated successfully');
          }
        },
        builder: (context, state) {
          // if (state is MeLoadingState && user == null) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          
           return Column(
            children: [
              ProfileHeader(
                user: user,
                onEditImage: _showImageSourcePicker,
                height: MediaQuery.of(context).size.height / 2,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 24),
                    InfoCard(
                      icon: Icons.person_outline,
                      title: 'Bio',
                      value: user?.bio ?? '',
                      onEdit: () => _editField('Bio', user?.bio ?? '', (val) {
                        context.read<AuthBloc>().add(UpdateMeEvent('bio', val));
                      }),
                    ),
                    InfoCard(
                      icon: Icons.cake_outlined,
                      title: 'Birthday',
                      value: user?.birthDate ?? '',
                      onEdit: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          final formattedDate =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          context.read<AuthBloc>().add(
                            UpdateMeEvent('birthday', formattedDate),
                          );
                        }
                      },
                    ),
                    InfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: user?.email ?? '',
                      onEdit: () => _editField(
                        'Email',
                        user?.email ?? '',
                        (val) {
                          context.read<AuthBloc>().add(
                            UpdateMeEvent('email', val),
                          );
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    InfoCard(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: user?.phoneNumber ?? '',
                      onEdit: () => _editField(
                        'Phone',
                        user?.phoneNumber ?? '',
                        (val) {
                          context.read<AuthBloc>().add(
                            UpdateMeEvent('phone_number', val),
                          );
                        },
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
