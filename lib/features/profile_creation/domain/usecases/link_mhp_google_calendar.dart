import '../../data/datasources/mhp_profile_remote_data_source.dart';

/// PATCH `/mhp/external/v1/google?token=` — stores OAuth tokens for Meet on the MHP profile.
class LinkMhpGoogleCalendar {
  LinkMhpGoogleCalendar(this._remote);

  final MhpProfileRemoteDataSource _remote;

  Future<void> call(String serverAuthCode) =>
      _remote.linkGoogleCalendar(serverAuthCode: serverAuthCode.trim());
}
