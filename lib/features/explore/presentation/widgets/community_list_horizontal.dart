import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/usecases/follow_community.dart';
import 'package:fly/features/community/domain/usecases/unfollow_community.dart';
import 'package:fly/features/start_quiz/widgets/community_card.dart';

class CommunityListHorizontal extends StatefulWidget {
  final List<Map<String, dynamic>> communities;
  /// IDs of communities the user has already joined (from user profile API).
  /// Used to show correct "joined" state on first load.
  final List<String>? initialJoinedCommunityIds;

  const CommunityListHorizontal({
    super.key,
    required this.communities,
    this.initialJoinedCommunityIds,
  });

  @override
  State<CommunityListHorizontal> createState() => _CommunityListHorizontalState();
}

class _CommunityListHorizontalState extends State<CommunityListHorizontal> {
  final Set<String> _joinedCommunities = {};
  // Track follower counts for each community (for optimistic updates)
  final Map<String, int> _followerCounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize follower counts from widget data
    for (var community in widget.communities) {
      final id = community['communityId'] as String;
      final count = community['followerCount'] as int;
      _followerCounts[id] = count;
    }
    // Seed joined state from user profile (followed_communities from backend)
    if (widget.initialJoinedCommunityIds != null) {
      _joinedCommunities.addAll(widget.initialJoinedCommunityIds!);
    }
  }

  @override
  void didUpdateWidget(CommunityListHorizontal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When profile first loads and provides initial IDs, sync joined state (don't overwrite after user toggles)
    if (widget.initialJoinedCommunityIds != null &&
        oldWidget.initialJoinedCommunityIds == null) {
      setState(() {
        _joinedCommunities.clear();
        _joinedCommunities.addAll(widget.initialJoinedCommunityIds!);
      });
    }
  }

  Future<void> _handleJoinToggle(String communityId, String communityName, bool isCurrentlyJoined) async {
    // Prevent duplicate operations - if already in the state we want, do nothing
    final willBeJoined = !isCurrentlyJoined;
    if (willBeJoined && _joinedCommunities.contains(communityId)) {
      print('⚠️ User already joined, skipping duplicate join');
      return;
    }
    if (!willBeJoined && !_joinedCommunities.contains(communityId)) {
      print('⚠️ User already left, skipping duplicate leave');
      return;
    }
    
    try {
      if (isCurrentlyJoined) {
        // Only decrement if user was actually joined
        if (_joinedCommunities.contains(communityId)) {
          setState(() {
            _joinedCommunities.remove(communityId);
            // Decrement follower count only if count > 0
            final currentCount = _followerCounts[communityId] ?? 0;
            if (currentCount > 0) {
              _followerCounts[communityId] = currentCount - 1;
            }
          });
        }
        
        // Unfollow community
        final unfollowCommunity = sl<UnfollowCommunity>();
        await unfollowCommunity.call(communityId);
        print('✅ Unfollowed community: $communityName');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left $communityName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Only increment if user wasn't already joined
        if (!_joinedCommunities.contains(communityId)) {
          setState(() {
            _joinedCommunities.add(communityId);
            // Increment follower count
            _followerCounts[communityId] = (_followerCounts[communityId] ?? 0) + 1;
          });
        }
        
        // Follow community
        final followCommunity = sl<FollowCommunity>();
        await followCommunity.call(communityId);
        print('✅ Followed community: $communityName');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined $communityName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error updating community membership: $e');
      // Revert optimistic UI updates on error
      setState(() {
        if (isCurrentlyJoined) {
          // Revert unfollow - add back to joined and increment count
          _joinedCommunities.add(communityId);
          _followerCounts[communityId] = (_followerCounts[communityId] ?? 0) + 1;
        } else {
          // Revert follow - remove from joined and decrement count
          _joinedCommunities.remove(communityId);
          _followerCounts[communityId] = (_followerCounts[communityId] ?? 0) - 1;
          if (_followerCounts[communityId]! < 0) {
            _followerCounts[communityId] = 0;
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.communities.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No communities available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150, // fixed height for horizontal scroll
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.communities.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final community = widget.communities[index];
          final communityId = community['communityId'] as String;
          final communityName = community['communityName'] as String;
          final isJoined = _joinedCommunities.contains(communityId);
          // Use updated follower count if available, otherwise use original
          final followerCount = _followerCounts[communityId] ?? 
                                (community['followerCount'] as int);
          
          return SizedBox(
            width: 160, // control card width
            child: CommunityCard(
              profilePicUrl: community['profilePicUrl'] as String,
              communityName: communityName,
              communityId: communityId,
              followerCount: followerCount,
              isSelected: isJoined,
              onJoin: () {
                _handleJoinToggle(communityId, communityName, isJoined);
              },
            ),
          );
        },
      ),
    );
  }
}
