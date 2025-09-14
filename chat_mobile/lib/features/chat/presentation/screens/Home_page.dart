import 'package:chat_mobile/features/chat/presentation/widgets/home_wdget/faveriet_card.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/home_wdget/profile_show.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/home_wdget/serch_bar.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/home_wdget/user_chat.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 100.0,
              maxHeight: 100.0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
            child: ProfileShow(),
          ),)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 32, top: 16, bottom: 16),
              child: Row(children: [
                const SearchBarr(), 
                Container(
                margin: const EdgeInsets.only(left: 16),
        
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 30),
                  onPressed: () {
                    // TODO: Implement search functionality
                  },
                ),
                ),
              ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 180.0,
              maxHeight: 180.0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 32, top: 16),
                        child: FaverietCard(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return const UserChat();
              },
              childCount: 20, // Example item count
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
