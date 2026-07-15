import 'package:flutter/material.dart';
import '../services/cached_data_loader.dart';

class CachedBuilder<T> extends StatefulWidget {
  final CachedDataLoader<T> loader;
  final Widget Function(BuildContext context, T data, bool isFromCache) builder;
  final Widget? skeleton;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final bool showRefreshIndicator;
  final Color? refreshIndicatorColor;

  const CachedBuilder({
    super.key,
    required this.loader,
    required this.builder,
    this.skeleton,
    this.errorBuilder,
    this.showRefreshIndicator = true,
    this.refreshIndicatorColor,
  });

  @override
  State<CachedBuilder<T>> createState() => _CachedBuilderState<T>();
}

class _CachedBuilderState<T> extends State<CachedBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.loader.addListener(_onStateChanged);
    widget.loader.load();
  }

  @override
  void dispose() {
    widget.loader.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.loader.state;

    if (state.showSkeleton) {
      return widget.skeleton ?? const _DefaultSkeleton();
    }

    if (state.hasError && !state.hasData) {
      return widget.errorBuilder?.call(context, state.error ?? 'Unknown error') ??
          _DefaultError(
            error: state.error ?? 'Unknown error',
            onRetry: () => widget.loader.refresh(),
          );
    }

    if (!state.hasData) {
      return widget.skeleton ?? const _DefaultSkeleton();
    }

    final content = Stack(
      children: [
        widget.builder(context, state.data as T, state.isFromCache),
        if (state.isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: widget.refreshIndicatorColor ??
                  Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
      ],
    );

    if (widget.showRefreshIndicator) {
      return RefreshIndicator(
        onRefresh: () => widget.loader.refresh(),
        color: widget.refreshIndicatorColor,
        child: content,
      );
    }

    return content;
  }
}

class _DefaultSkeleton extends StatelessWidget {
  const _DefaultSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _DefaultError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _DefaultError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CachedListBuilder<T> extends StatefulWidget {
  final CachedDataLoader<List<T>> loader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? skeleton;
  final Widget? emptyWidget;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const CachedListBuilder({
    super.key,
    required this.loader,
    required this.itemBuilder,
    this.skeleton,
    this.emptyWidget,
    this.errorBuilder,
    this.padding,
    this.separatorBuilder,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<CachedListBuilder<T>> createState() => _CachedListBuilderState<T>();
}

class _CachedListBuilderState<T> extends State<CachedListBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.loader.addListener(_onStateChanged);
    widget.loader.load();
  }

  @override
  void dispose() {
    widget.loader.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.loader.state;

    if (state.showSkeleton) {
      return widget.skeleton ?? const _DefaultSkeleton();
    }

    if (state.hasError && !state.hasData) {
      return widget.errorBuilder?.call(context, state.error ?? 'Unknown error') ??
          _DefaultError(
            error: state.error ?? 'Unknown error',
            onRetry: () => widget.loader.refresh(),
          );
    }

    final data = state.data;
    if (data == null || data.isEmpty) {
      return widget.emptyWidget ?? const SizedBox();
    }

    Widget list;
    if (widget.separatorBuilder != null) {
      list = ListView.separated(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: data.length,
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) =>
            widget.itemBuilder(context, data[index], index),
      );
    } else {
      list = ListView.builder(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: data.length,
        itemBuilder: (context, index) =>
            widget.itemBuilder(context, data[index], index),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.loader.refresh(),
      child: Stack(
        children: [
          list,
          if (state.isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
