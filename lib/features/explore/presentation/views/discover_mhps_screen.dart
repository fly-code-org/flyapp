import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/entities/explore_search_result.dart';
import 'package:fly/features/community/domain/usecases/get_discover_mhps.dart';
import 'package:fly/features/community/domain/usecases/search_explore.dart';
import 'package:fly/features/explore/presentation/widgets/mhp_discover_card.dart';

/// Full "Discover Mental Health Professionals" list (Explore "See All").
///
/// Empty search box -> paginated list of all MHPs (GET .../explore/mhps).
/// Non-empty -> server search results (GET .../explore/search).
class DiscoverMhpsScreen extends StatefulWidget {
  const DiscoverMhpsScreen({super.key});

  @override
  State<DiscoverMhpsScreen> createState() => _DiscoverMhpsScreenState();
}

class _DiscoverMhpsScreenState extends State<DiscoverMhpsScreen> {
  static const _pageSize = 20;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<ExploreSearchMhp> _mhps = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _searching = false; // true while showing search results
  int _skip = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searching || _loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _searching = false;
      _skip = 0;
      _hasMore = true;
      _mhps.clear();
    });
    try {
      final res = await sl<GetDiscoverMhps>().call(skip: 0, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _mhps.addAll(res.mhps);
        _skip = res.skip + res.mhps.length;
        _hasMore = res.hasMore;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    setState(() => _loadingMore = true);
    try {
      final res = await sl<GetDiscoverMhps>().call(skip: _skip, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _mhps.addAll(res.mhps);
        _skip = res.skip + res.mhps.length;
        _hasMore = res.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = value.trim();
      if (q.isEmpty) {
        _loadFirstPage();
      } else {
        _runSearch(q);
      }
    });
  }

  Future<void> _runSearch(String q) async {
    setState(() {
      _loading = true;
      _error = null;
      _searching = true;
      _hasMore = false;
      _mhps.clear();
    });
    try {
      final res = await sl<SearchExplore>().call(q);
      if (!mounted) return;
      setState(() {
        _mhps.addAll(res.mhps);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Discover Mental Health\nProfessionals',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.15,
          ),
        ),
        toolbarHeight: 72,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search for concern - anxiety, career, marriage more.',
                hintStyle: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF2F2F4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _StateMessage(
        message: 'Could not load professionals.\n$_error',
        onRetry: _loadFirstPage,
      );
    }
    if (_mhps.isEmpty) {
      return _StateMessage(
        message: _searching
            ? 'No professionals match your search.'
            : 'No professionals available yet.',
        onRetry: _searching ? null : _loadFirstPage,
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.74,
      ),
      itemCount: _mhps.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _mhps.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return MhpDiscoverCard(mhp: _mhps[index]);
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _StateMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
