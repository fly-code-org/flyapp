/// User-facing copy for MHP profile (third tab: own = sessions hub, visitor = connect).
const String mhpProfileSessionsTabLabel = 'Sessions';
const String mhpProfileConnectTabLabel = 'Connect';

/// When [viewingOther] is true (visitor on another MHP's profile), show Connect; otherwise Sessions.
String mhpProfileThirdTabTitle({required bool viewingOther}) =>
    viewingOther ? mhpProfileConnectTabLabel : mhpProfileSessionsTabLabel;
