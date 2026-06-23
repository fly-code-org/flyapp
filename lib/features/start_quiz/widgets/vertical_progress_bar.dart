import 'package:flutter/material.dart';

const _kOptionHeight = 88.0;
const _kKnobSize = 48.0;
const _kBarWidth = 6.0;
const _kKnobColor = Color(0xFF7B68D9);
const _kFillColorBottom = Color(0xFF6B5BD6);
const _kFillColorTop = Color(0xFF9B8FE8);
const _kBarGray = Color(0xFFE0E0E0);
const _kSelectedLabelColor = Color(0xFF7B68D9);
const _kUnselectedLabelColor = Color(0xFF9E9E9E);
const _kAnimDuration = Duration(milliseconds: 150);

class VerticalOptionsSelector extends StatefulWidget {
  final List<String> leftLabels;
  final List<String> rightLabels;
  final Function(int index, String optionId)? onOptionSelected;

  const VerticalOptionsSelector({
    super.key,
    required this.leftLabels,
    required this.rightLabels,
    this.onOptionSelected,
  });

  @override
  State<VerticalOptionsSelector> createState() =>
      _VerticalOptionsSelectorState();
}

class _VerticalOptionsSelectorState extends State<VerticalOptionsSelector> {
  // 0 = bottom option, length-1 = top option
  int selectedIndex = 0;

  int get _numOptions => widget.leftLabels.length;
  double get _totalHeight => _numOptions * _kOptionHeight;

  // selectedIndex (0=bottom) → visual row index (0=top)
  int _visualIndex(int sIdx) => _numOptions - 1 - sIdx;

  void _updateIndex(int newIndex) {
    if (newIndex == selectedIndex) return;
    setState(() => selectedIndex = newIndex);
    widget.onOptionSelected?.call(selectedIndex, selectedIndex.toString());
  }

  int _indexFromLocalY(double localY) {
    // Option at selectedIndex has its center at:
    //   (numOptions - 0.5 - selectedIndex) * optionHeight from top
    // Inverting: selectedIndex = numOptions - 0.5 - localY/optionHeight
    return (((_totalHeight - localY) / _kOptionHeight) - 0.5)
        .round()
        .clamp(0, _numOptions - 1);
  }

  // ── bar geometry ──────────────────────────────────────────────────────────
  // Bar spans from center of top option to center of bottom option.
  //   barTopInset    = optionHeight/2  (from top of Stack)
  //   barBottomInset = optionHeight/2  (from bottom of Stack)
  //   barHeight      = (numOptions-1) * optionHeight
  //
  // Knob: center aligns with the center of the selected option row.
  //   knob center from bottom of Stack = (selectedIndex + 0.5) * optionHeight
  //   knob bottom edge (Positioned.bottom) = knob_center - knobSize/2
  //
  // Fill: from bottom of bar up to knob center.
  //   fill bottom (Positioned.bottom) = optionHeight/2
  //   fill height = selectedIndex * optionHeight

  double get _knobBottom =>
      (selectedIndex + 0.5) * _kOptionHeight - _kKnobSize / 2;
  double get _fillHeight => selectedIndex * _kOptionHeight;
  double get _barHeight => (_numOptions - 1) * _kOptionHeight;
  double get _barTopInset => _kOptionHeight / 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left labels ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: List.generate(_numOptions, (visualIdx) {
                final isSelected = _visualIndex(selectedIndex) == visualIdx;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _updateIndex(_numOptions - 1 - visualIdx),
                  child: SizedBox(
                    height: _kOptionHeight,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          widget.leftLabels[visualIdx],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? _kSelectedLabelColor
                                : _kUnselectedLabelColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Bar + knob ────────────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _updateIndex(_indexFromLocalY(d.localPosition.dy)),
            onVerticalDragUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final localY = box.globalToLocal(d.globalPosition).dy;
              _updateIndex(_indexFromLocalY(localY));
            },
            child: SizedBox(
              width: _kKnobSize + 8,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Gray background bar
                  Positioned(
                    top: _barTopInset,
                    child: Container(
                      width: _kBarWidth,
                      height: _barHeight,
                      decoration: BoxDecoration(
                        color: _kBarGray,
                        borderRadius: BorderRadius.circular(_kBarWidth / 2),
                      ),
                    ),
                  ),

                  // Purple fill (bottom of bar → knob center)
                  Positioned(
                    bottom: _kOptionHeight / 2,
                    child: AnimatedContainer(
                      duration: _kAnimDuration,
                      curve: Curves.easeOut,
                      width: _kBarWidth,
                      height: _fillHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kFillColorBottom, _kFillColorTop],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(_kBarWidth / 2),
                      ),
                    ),
                  ),

                  // Knob
                  AnimatedPositioned(
                    duration: _kAnimDuration,
                    curve: Curves.easeOut,
                    bottom: _knobBottom,
                    child: Container(
                      width: _kKnobSize,
                      height: _kKnobSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kKnobColor,
                        boxShadow: [
                          BoxShadow(
                            color: _kKnobColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.unfold_more,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right labels (emojis) ─────────────────────────────────────────
          Expanded(
            child: Column(
              children: List.generate(_numOptions, (visualIdx) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _updateIndex(_numOptions - 1 - visualIdx),
                  child: SizedBox(
                    height: _kOptionHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          widget.rightLabels[visualIdx],
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Standalone test ──────────────────────────────────────────────────────────

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VerticalOptionsSelector(
          leftLabels: const [
            "Top priority",
            "Really matters",
            "Somewhat important",
            "Nice to have",
            "Doesn't matter",
          ],
          rightLabels: const ["🤩", "😀", "😊", "😐", "😟"],
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: TestScreen()));
