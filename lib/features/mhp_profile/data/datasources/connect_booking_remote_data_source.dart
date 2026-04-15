import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fly/core/error/exceptions.dart';
import 'package:fly/core/network/api_client.dart';
import 'package:fly/features/mhp_profile/data/models/connect_booking_models.dart';

class ConnectReceiptResult {
  const ConnectReceiptResult._({this.redirectUrl, this.pdfBytes});

  factory ConnectReceiptResult.redirect(String url) =>
      ConnectReceiptResult._(redirectUrl: url.trim());

  factory ConnectReceiptResult.pdf(Uint8List bytes) =>
      ConnectReceiptResult._(pdfBytes: bytes);

  final String? redirectUrl;
  final Uint8List? pdfBytes;
}

/// fly-be `connect/external/v1` — seeker JWT required.
abstract class ConnectBookingRemoteDataSource {
  Future<List<ConnectOfferOption>> getOffers(String mhpUserId);

  Future<ConnectAvailabilityResult> getAvailability({
    required String mhpUserId,
    required String weekStartYyyyMmDd,
    required String therapyOfferId,
    required int durationMinutes,
    required String preferenceApi,
  });

  Future<ConnectHoldResult> createHold({
    required String mhpUserId,
    required String therapyOfferId,
    String? therapyTypeId,
    required String preferenceApi,
    required int durationMinutes,
    required String startAtRfc3339,
  });

  Future<ConnectPreparePaymentResult> prepareRazorpayOrder(String bookingId);

  Future<ConnectConfirmResult> confirmPayment(
    String bookingId, {
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  Future<ConnectReceiptResult> getReceipt(String bookingId);
}

class ConnectBookingRemoteDataSourceImpl
    implements ConnectBookingRemoteDataSource {
  ConnectBookingRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  static const _basePath = '/connect/external/v1';

  Object? _unwrapData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['msg'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is Map) {
        for (final entry in msg.entries) {
          final v = entry.value;
          if (v is String && v.isNotEmpty) return v;
        }
      }
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
    }
    return e.message ?? 'Request failed';
  }

  Never _throwDio(DioException e) {
    final code = e.response?.statusCode;
    final msg = _messageFromDio(e);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException('Connection timeout. Check your network.');
    }
    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException('No internet connection.');
    }
    if (code == 401) {
      throw AuthException(msg);
    }
    if (code == 403) {
      throw AuthException(msg);
    }
    throw ServerException(msg, statusCode: code);
  }

  @override
  Future<List<ConnectOfferOption>> getOffers(String mhpUserId) async {
    try {
      final response = await _dio.get('$_basePath/mhp/$mhpUserId/offers');
      final raw = _unwrapData(response);
      if (raw is! List) return [];
      return raw
          .map((e) => ConnectOfferOption.fromJson(e))
          .whereType<ConnectOfferOption>()
          .toList();
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  @override
  Future<ConnectAvailabilityResult> getAvailability({
    required String mhpUserId,
    required String weekStartYyyyMmDd,
    required String therapyOfferId,
    required int durationMinutes,
    required String preferenceApi,
  }) async {
    try {
      final response = await _dio.get(
        '$_basePath/mhp/$mhpUserId/availability',
        queryParameters: {
          'week_start': weekStartYyyyMmDd,
          'therapy_offer_id': therapyOfferId,
          'duration_minutes': durationMinutes,
          'preference': preferenceApi,
        },
      );
      final raw = _unwrapData(response);
      return ConnectAvailabilityResult.fromJson(raw);
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  @override
  Future<ConnectHoldResult> createHold({
    required String mhpUserId,
    required String therapyOfferId,
    String? therapyTypeId,
    required String preferenceApi,
    required int durationMinutes,
    required String startAtRfc3339,
  }) async {
    try {
      final body = <String, dynamic>{
        'mhp_user_id': mhpUserId,
        'therapy_offer_id': therapyOfferId,
        'preference': preferenceApi,
        'duration_minutes': durationMinutes,
        'start_at': startAtRfc3339,
      };
      if (therapyTypeId != null && therapyTypeId.isNotEmpty) {
        body['therapy_type_id'] = therapyTypeId;
      }
      final response = await _dio.post('$_basePath/bookings', data: body);
      final raw = _unwrapData(response);
      return ConnectHoldResult.fromJson(raw);
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  @override
  Future<ConnectPreparePaymentResult> prepareRazorpayOrder(
    String bookingId,
  ) async {
    try {
      final response = await _dio.post(
        '$_basePath/bookings/$bookingId/razorpay-order',
      );
      final raw = _unwrapData(response);
      final parsed = ConnectPreparePaymentResult.fromJson(raw);
      if (parsed == null) {
        throw ServerException(
          'Invalid payment order response',
          statusCode: response.statusCode,
        );
      }
      return parsed;
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  @override
  Future<ConnectConfirmResult> confirmPayment(
    String bookingId, {
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dio.post(
        '$_basePath/bookings/$bookingId/confirm-payment',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      final raw = _unwrapData(response);
      return ConnectConfirmResult.fromJson(raw);
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  @override
  Future<ConnectReceiptResult> getReceipt(String bookingId) async {
    try {
      final response = await _dio.get(
        '$_basePath/bookings/$bookingId/receipt',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          headers: {'Accept': 'application/pdf'},
          validateStatus: (code) => code != null && code >= 200 && code < 400,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 300 && statusCode < 400) {
        final redirectUrl = response.headers.value('location')?.trim();
        if (redirectUrl == null || redirectUrl.isEmpty) {
          throw ServerException(
            'Receipt redirect is unavailable right now.',
            statusCode: statusCode,
          );
        }
        return ConnectReceiptResult.redirect(redirectUrl);
      }

      final body = response.data;
      if (body is Uint8List && body.isNotEmpty) {
        return ConnectReceiptResult.pdf(body);
      }
      if (body is List<int> && body.isNotEmpty) {
        return ConnectReceiptResult.pdf(Uint8List.fromList(body));
      }
      throw ServerException('Receipt data is empty.', statusCode: statusCode);
    } on DioException catch (e) {
      _throwDio(e);
    }
  }
}
