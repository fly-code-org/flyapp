import 'package:flutter/material.dart';
import 'package:fly/features/mhp_profile/presentation/widgets/mhp_visitor_connect_booking_tab.dart';

const _purple = Color(0xFF855DFC);

/// Sticky "Let's connect" bar rendered by the host (MhpProfileScreen) when
/// the visitor is on the Connect tab in embedded mode.
class ConnectBookingStickyBar extends StatelessWidget {
  final ConnectBookingBarState state;

  const ConnectBookingStickyBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.summaryLine1.isNotEmpty)
                Text(
                  state.summaryLine1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                state.summaryLine2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.canConnect && !state.busy
                      ? () => state.onConnect?.call()
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Let's connect",
                          style: TextStyle(
                            
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
