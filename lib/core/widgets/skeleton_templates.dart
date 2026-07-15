import 'package:flutter/material.dart';
import 'skeleton.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SkeletonAvatar(size: 100),
          const SizedBox(height: 16),
          const SkeletonLine(width: 150, height: 20),
          const SizedBox(height: 8),
          const SkeletonLine(width: 100, height: 14),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(),
              _statItem(),
              _statItem(),
            ],
          ),
          const SizedBox(height: 24),
          const Skeleton(width: double.infinity, height: 44, borderRadius: 22),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLine(width: 80, height: 16),
          ),
          const SizedBox(height: 12),
          const SkeletonParagraph(lines: 3),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLine(width: 120, height: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              5,
              (_) => const Skeleton(width: 80, height: 32, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem() {
    return const Column(
      children: [
        SkeletonLine(width: 40, height: 20),
        SizedBox(height: 4),
        SkeletonLine(width: 60, height: 12),
      ],
    );
  }
}

class PostListSkeleton extends StatelessWidget {
  final int itemCount;

  const PostListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const PostItemSkeleton(),
    );
  }
}

class PostItemSkeleton extends StatelessWidget {
  const PostItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonAvatar(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                        width: MediaQuery.of(context).size.width * 0.3),
                    const SizedBox(height: 6),
                    SkeletonLine(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 10),
                  ],
                ),
              ),
              const Skeleton(width: 24, height: 24, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonParagraph(lines: 2),
          const SizedBox(height: 12),
          const Skeleton(
              width: double.infinity, height: 180, borderRadius: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              const Skeleton(width: 60, height: 24, borderRadius: 12),
              const SizedBox(width: 16),
              const Skeleton(width: 60, height: 24, borderRadius: 12),
              const Spacer(),
              const Skeleton(width: 24, height: 24, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostListSkeleton(itemCount: 4);
  }
}

class JournalListSkeleton extends StatelessWidget {
  final int itemCount;

  const JournalListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const JournalItemSkeleton(),
    );
  }
}

class JournalItemSkeleton extends StatelessWidget {
  const JournalItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Skeleton(width: 48, height: 48, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: MediaQuery.of(context).size.width * 0.5),
                const SizedBox(height: 6),
                SkeletonLine(
                    width: MediaQuery.of(context).size.width * 0.3, height: 10),
              ],
            ),
          ),
          const Skeleton(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}

class ChatListSkeleton extends StatelessWidget {
  final int itemCount;

  const ChatListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, __) => const ChatItemSkeleton(),
    );
  }
}

class ChatItemSkeleton extends StatelessWidget {
  const ChatItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SkeletonAvatar(size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonLine(
                          width: MediaQuery.of(context).size.width * 0.35),
                    ),
                    const SkeletonLine(width: 40, height: 10),
                  ],
                ),
                const SizedBox(height: 6),
                SkeletonLine(
                    width: MediaQuery.of(context).size.width * 0.5, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsListSkeleton extends StatelessWidget {
  final int itemCount;

  const SettingsListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const SettingsItemSkeleton(),
    );
  }
}

class SettingsItemSkeleton extends StatelessWidget {
  const SettingsItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Skeleton(width: 24, height: 24, borderRadius: 6),
          const SizedBox(width: 12),
          Expanded(
            child: SkeletonLine(width: MediaQuery.of(context).size.width * 0.4),
          ),
          const Skeleton(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double aspectRatio;

  const GridSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.aspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const Skeleton(borderRadius: 12),
    );
  }
}
