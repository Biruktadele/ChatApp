import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mobile/core/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constant/api_constant.dart';
import '../../../chat/presentation/screens/fullscreen_image_viewer.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  User? user = User();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthBloc>().add(const GetMe());
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // context.read<AuthBloc>().add(const GetMe());

    // BlocListener<AuthBloc, AuthState>(
    //   listener: (context, state) {
    //     if (state is GetMeSuccess) {
    //       debugPrint('GetMeSuccess🎁🎁🎁🎁 Yes');
    //       setState(() {
    //         user = state.user;
    //       });
    //     }
    //   },
    //   child: Container(),
    // );
  }

  // Example data, replace with real data from your state / bloc

  final List<String> _interests = [
    'Photography',
    'Hiking',
    'Yoga',
    'Cooking',
    'Art',
  ];

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Take photo action')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () async {
                ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  final bytes = await image.readAsBytes();
                  context.read<AuthBloc>().add(UpdatePhoto(bytes));
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
    Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueGrey,
            onPrimary: Colors.white,
            surface: Color(0xFF121212),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Colors.grey.shade900,
        ),
        child: AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            keyboardType: title == 'Phone'
                ? TextInputType.phone
                : TextInputType.multiline,
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        onSave(result);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title updated')));
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // A simple format, you can use the intl package for more complex formatting
        user?.birthDate = "${picked.month}/${picked.day}/${picked.year}";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Birthday updated')));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildImageCarousel(double height) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              if (user?.avatar == null || user!.avatar!.isEmpty) return;
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, __, ___) => FullScreenImageViewer(
                    images: ['$cloudinaryUrl${user?.avatar ?? ''}'],
                    initialIndex: 0,
                    heroTagPrefix: 'profile_image_',
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'profile_image_0',
              child: (user?.avatar != null && user!.avatar!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: cloudinaryUrl + user!.avatar!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade800),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 150,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 150,
                      ),
                    ),
            ),
          ),
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 0.7, 1.0],
              ),
            ),
          ),
          // Top bar with back button and edit
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassIconButton(
                  icon: Icons.arrow_back,
                  onPressed: widget.onBack,
                ),
                _buildGlassIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: _showImageSourcePicker,
                ),
              ],
            ),
          ),
          // bottom left: name
          Positioned(
            left: 24,
            bottom: 20,
            right: 24,
            child: Text(
              user?.username ?? 'No Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black54,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.5; // Use 50% of screen height
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is GetMeSuccess) {
            debugPrint('GetMeSuccess🎁🎁🎁🎁 Yes');
            setState(() {
              user = state.user;
            });
          }
          if (state is MeFailure) {
            _showSnackbar(state.failure.toString());
          }
          if (state is MeUpdateSuccess) {
            setState(() {
              user = state.user;
            });
            _showSnackbar('Profile updated successfully');
          }
        },
        builder: (context, state) {
          if (state is MeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: topHeight,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(topHeight),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildSectionContainer([
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Bio',
                      value: user?.bio ?? '',
                      onEdit: () => _editField('Bio', user?.bio ?? '', (val) {
                        context.read<AuthBloc>().add(UpdateMe('bio', val));
                        user?.bio = val;
                      }),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildInfoTile(
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
                            UpdateMe('birthday', formattedDate),
                          );
                          setState(() {
                            user?.birthDate = formattedDate;
                          });
                        }
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Email',
                      value: user?.email ?? '',
                      onEdit: () => _editField('Email', user?.email ?? '', (
                        val,
                      ) {
                        context.read<AuthBloc>().add(UpdateMe('email', val));
                        user?.email = val;
                      }),
                    ),
                    const Divider(indent: 16, endIndent: 16), // NEW
                    _buildInfoTile(
                      // NEW
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: user?.phoneNumber ?? '',
                      onEdit: () =>
                          _editField('Phone', user?.phoneNumber ?? '', (val) {
                            context.read<AuthBloc>().add(
                              UpdateMe('phone_number', val),
                            );
                            user?.phoneNumber = val;
                          }),
                    ),
                  ]),
                  _buildSectionContainer([
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Interests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              _showSnackbar('Interest editing not implemented');
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: _interests
                            .map(
                              (interest) => Chip(
                                label: Text(
                                  interest,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Colors.grey.shade800,
                                side: BorderSide(color: Colors.grey.shade700),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 50),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
