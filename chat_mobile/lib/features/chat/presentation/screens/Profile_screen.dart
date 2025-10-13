import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'fullscreen_image_viewer.dart'; // NEW import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController(); // NEW
  int _currentPage = 0;
  double _scrollOffset = 0.0; // NEW

  // Example data, replace with real data from your state / bloc
  final List<String> _images = [
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=1887&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1887&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1887&auto=format&fit=crop',
  ];
  String _name = 'Jessica, 24';
  String _phone = '+1 555 123 4567';
  String _bio =
      'Llover of art, travel, and spontaneous adventures. Looking for someone to share a pizza with. 🍕'
          .replaceFirst('Llover', 'Lover');
  String _birthday = 'August 12, 1998';
  String _location = 'San Francisco, CA';
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
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Choose from gallery action')),
                );
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
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: title == 'Phone'
              ? TextInputType.phone
              : TextInputType.multiline,
          maxLines: title == 'Bio' ? 5 : 1,
          decoration: InputDecoration(hintText: 'Enter your $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
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
        _birthday = "${picked.month}/${picked.day}/${picked.year}";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Birthday updated')));
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      // NEW listener
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose(); // NEW
    super.dispose();
  }

  // NEW helper: animated section wrapper
  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final baseDelay = 120.0; // scroll distance to start
    final step = 160.0; // distance between section reveals
    final start = baseDelay + (index * step);
    final end = start + 180.0; // fade range
    double opacity;
    if (_scrollOffset <= start) {
      opacity = 0.0;
    } else if (_scrollOffset >= end) {
      opacity = 1.0;
    } else {
      opacity = (_scrollOffset - start) / (end - start);
    }
    final translateY = (1 - opacity) * 24.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(0, translateY), child: child),
    );
  }

  Widget _buildImageCarousel(double height) {
    final blurSigma = (_scrollOffset / 90).clamp(0.0, 12.0); // NEW dynamic blur
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              double scale = 1.0;
              double opacity = 1.0;
              if (_pageController.position.haveDimensions) {
                double page = _pageController.page ?? 0.0;
                scale = (1 - (page - index).abs() * 0.3).clamp(0.8, 1.0);
                opacity = (1 - (page - index).abs() * 0.5).clamp(0.5, 1.0);
              }
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => FullScreenImageViewer(
                        images: _images,
                        initialIndex: index,
                        heroTagPrefix: 'profile_image_',
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'profile_image_$index',
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: Image.network(_images[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              );
            },
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
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _buildGlassIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: _showImageSourcePicker,
                ),
              ],
            ),
          ),
          // Page indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 60,
            right: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage >= i
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // bottom left: name
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Text(
              _name,
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
          // NEW scroll hint arrow (hidden after slight scroll)
          Positioned(
            bottom: 8 + MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _scrollOffset < 20 ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 36,
                    ),
                  ],
                ),
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
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
        onPressed: onEdit,
      ),
      onTap: onEdit,
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // NEW
    final topHeight = size.height; // CHANGED: was 60% height
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        controller: _scrollController, // NEW controller
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
              _buildAnimatedSection(
                index: 0,
                child: _buildSectionContainer([
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Bio',
                    value: _bio,
                    onEdit: () => _editField('Bio', _bio, (val) => _bio = val),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoTile(
                    icon: Icons.cake_outlined,
                    title: 'Birthday',
                    value: _birthday,
                    onEdit: _pickDate,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: _location,
                    onEdit: () => _editField(
                      'Location',
                      _location,
                      (val) => _location = val,
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16), // NEW
                  _buildInfoTile(
                    // NEW
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: _phone,
                    onEdit: () =>
                        _editField('Phone', _phone, (val) => _phone = val),
                  ),
                ]),
              ),
              _buildAnimatedSection(
                index: 1,
                child: _buildSectionContainer([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Interests',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Interest editing not implemented',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _interests
                          .map(
                            (interest) => Chip(
                              label: Text(interest),
                              backgroundColor: Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 50),
            ]),
          ),
        ],
      ),
    );
  }
}
