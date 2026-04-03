import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart'
    show BuildContext, MediaQuery, ScaffoldMessenger, SnackBar, Text, TimeOfDay;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_supported_platform.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/multiplatform/file_download/download_bytes.dart'
    as file_download;
import 'package:leadership/utils/slugify.dart' as slugify;
import 'package:leadership/versioning/build_version.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

const _baseDomainDefine = String.fromEnvironment(DefineKeys.baseDomain);
const _socketDomainDefine = String.fromEnvironment(DefineKeys.socketDomain);
const _socketKeyDefine = String.fromEnvironment(DefineKeys.socketKey);
const _azureConnStringDefine = String.fromEnvironment(
  DefineKeys.azureConnString,
);
const _appIdDefine = String.fromEnvironment(DefineKeys.appId);
const _appSecretDefine = String.fromEnvironment(DefineKeys.appSecret);
const _hiveEncryptionKeyDefine = String.fromEnvironment(
  DefineKeys.hiveEncryptionKey,
);

class Misc {
  // Private constructor to prevent instantiation
  Misc._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Cache for timezone locations to improve performance
  static final Map<String, tz.Location> _timezoneCache = {};

  /// Get timezone location with caching
  static tz.Location _getTimezoneLocation(String timezone) {
    return _timezoneCache.putIfAbsent(timezone, () {
      try {
        return tz.getLocation(timezone);
      } catch (e) {
        // Fallback to UTC if timezone is invalid
        return tz.getLocation('UTC');
      }
    });
  }

  /// Convert UTC DateTime to timezone-aware DateTime
  static tz.TZDateTime _toTimezone(DateTime dateTime, String timezone) {
    final location = _getTimezoneLocation(timezone);
    final universalTime = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return tz.TZDateTime.from(universalTime, location);
  }

  /// Format DateTime with enhanced error handling
  static String formatDateTime(
    DateTime dateTime,
    String timezone, {
    String? locale,
  }) {
    try {
      final dateTimeInLocation = _toTimezone(dateTime, timezone);
      final formatter = locale != null
          ? DateFormat.yMMMd(locale).add_jm().add_EEEE()
          : DateFormat.yMMMd().add_jm().add_EEEE();
      return formatter.format(dateTimeInLocation);
    } catch (e) {
      return dateTime.toString(); // Fallback to default string representation
    }
  }

  /// Format mission date with enhanced error handling
  static String formatMissionDate(
    DateTime dateTime,
    String timezone, {
    String? locale,
  }) {
    try {
      final dateTimeInLocation = _toTimezone(dateTime, timezone);
      final formatter = locale != null
          ? DateFormat.EEEE(locale).add_yMMMd()
          : DateFormat.EEEE().add_yMMMd();
      return formatter.format(dateTimeInLocation);
    } catch (e) {
      return DateFormat.yMMMd().format(dateTime);
    }
  }

  /// Format date with enhanced error handling
  static String formatDate(
    DateTime dateTime,
    String timezone, {
    String? locale,
  }) {
    try {
      final dateTimeInLocation = _toTimezone(dateTime, timezone);
      final formatter = locale != null
          ? DateFormat.yMMMMd(locale)
          : DateFormat.yMMMMd();
      return formatter.format(dateTimeInLocation);
    } catch (e) {
      return DateFormat.yMMMMd().format(dateTime);
    }
  }

  static String timestamp(
    DateTime dateTime,
    String timezone, {
    String? locale,
  }) {
    try {
      final dateTimeInLocation = _toTimezone(dateTime, timezone);
      final dateFormatter = locale != null
          ? DateFormat.yMMMMEEEEd(locale)
          : DateFormat.yMMMMEEEEd();
      final timeFormatter = locale != null
          ? DateFormat.jm(locale)
          : DateFormat.jm();

      return '${dateFormatter.format(dateTimeInLocation)} '
          '${timeFormatter.format(dateTimeInLocation)}';
    } catch (e) {
      return dateTime.toString();
    }
  }

  static String formatTime(String time, String timezone, {String? locale}) {
    try {
      // More robust time parsing
      final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$');
      final match = timeRegex.firstMatch(time);

      if (match == null) {
        throw ArgumentError('Invalid time format: $time');
      }

      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final second = int.tryParse(match.group(3) ?? '0') ?? 0;

      // Create a proper DateTime object
      final dateTimeUtc = DateTime.utc(2012, 2, 27, hour, minute, second);
      final location = _getTimezoneLocation(timezone);
      final dateTimeInLocation = tz.TZDateTime.from(dateTimeUtc, location);

      final formatter = locale != null
          ? DateFormat.jm(locale)
          : DateFormat.jm();
      return formatter.format(dateTimeInLocation);
    } catch (e) {
      return time; // Return original time if parsing fails
    }
  }

  /// Format time from DateTime with enhanced error handling
  static String formatTimeFromDateTime(
    DateTime dateTime,
    String timezone, {
    String? locale,
  }) {
    try {
      final dateTimeInLocation = _toTimezone(dateTime, timezone);
      final formatter = locale != null
          ? DateFormat.jm(locale)
          : DateFormat.jm();
      return formatter.format(dateTimeInLocation);
    } catch (e) {
      return DateFormat.jm().format(dateTime);
    }
  }

  static String getUserNameInitials(String userName, {int maxInitials = 2}) {
    final trimmedName = userName.trim();
    if (trimmedName.isEmpty) return 'U';

    final words = trimmedName.split(RegExp(r'\s+'));
    final initials = StringBuffer();

    for (var i = 0; i < min(words.length, maxInitials); i++) {
      if (words[i].isNotEmpty) {
        initials.write(words[i][0].toUpperCase());
      }
    }

    return initials.isEmpty ? 'U' : initials.toString();
  }

  static double truncateToDecimalPlaces(double value, int fractionalDigits) {
    if (fractionalDigits < 0) {
      throw ArgumentError('Fractional digits cannot be negative');
    }
    if (!value.isFinite) return value;

    final multiplier = pow(10, fractionalDigits);
    return (value * multiplier).truncate() / multiplier;
  }

  /// Round to decimal places (alternative to truncate)
  static double roundToDecimalPlaces(double value, int fractionalDigits) {
    if (fractionalDigits < 0) {
      throw ArgumentError('Fractional digits cannot be negative');
    }
    if (!value.isFinite) return value;

    final multiplier = pow(10, fractionalDigits);
    return (value * multiplier).round() / multiplier;
  }

  static String getFullAppVersion() {
    try {
      return packageVersion.trim();
    } catch (e) {
      return '0.0.0'; // Fallback version
    }
  }

  static String getAppVersion() {
    try {
      final version = packageVersion.trim();
      return version.length > 7 ? version.split('+')[0] : version;
    } catch (e) {
      return '0.0.0';
    }
  }

  static String getSluggedAppVersion() {
    try {
      return slugify.slugify(getAppVersion());
    } catch (e) {
      return '0-0-0';
    }
  }

  static bool userCan(PRFPermissions permission) {
    try {
      final user = getIt<HiveService>().auth.retrieveProfile();
      if (user == null) return false;

      // Cache user permissions for better performance
      final userPermissions = user.roles
          .expand((role) => role.permissions)
          .map((p) => p.name)
          .toSet();

      return userPermissions.contains(permission.key);
    } catch (e) {
      return false; // Deny access on error
    }
  }

  static Future<bool> openUrl(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String getFileName(String path) {
    if (path.isEmpty) return '';

    final lastSlashIndex = path.lastIndexOf('/');
    if (lastSlashIndex == -1) return path;

    final fileName = path.substring(lastSlashIndex + 1);
    return fileName.isEmpty ? path : fileName;
  }

  static String formatCash(
    num amount, {
    String locale = 'en_KE',
    String symbol = '',
    int decimalDigits = 0,
    String? customSymbol,
  }) {
    try {
      final formatter = NumberFormat.currency(
        locale: locale,
        symbol: customSymbol ?? symbol,
        decimalDigits: decimalDigits,
      );
      return formatter.format(amount);
    } catch (e) {
      return amount.toString();
    }
  }

  static double getScaleFactor(
    BuildContext context, {
    double? customBaseWidth,
    double? minScale,
    double? maxScale,
  }) {
    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final deviceType = getDeviceType(context);

      // Dynamic base widths based on device type
      final baseWidth =
          customBaseWidth ??
          switch (deviceType) {
            DeviceType.phone => 375.0,
            DeviceType.tablet => 600.0,
            DeviceType.desktop => 1200.0,
          };

      final scaleFactor = screenWidth / baseWidth;

      // Dynamic scale ranges based on device type
      final minScaleValue =
          minScale ??
          switch (deviceType) {
            DeviceType.phone => 0.8,
            DeviceType.tablet => 0.7,
            DeviceType.desktop => 0.6,
          };

      final maxScaleValue =
          maxScale ??
          switch (deviceType) {
            DeviceType.phone => 1.4,
            DeviceType.tablet => 1.6,
            DeviceType.desktop => 2.0,
          };

      return scaleFactor.clamp(minScaleValue, maxScaleValue);
    } catch (e) {
      return 1; // Fallback to no scaling
    }
  }

  /// Get device type based on screen size
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) return DeviceType.desktop;
    if (screenWidth >= 600) return DeviceType.tablet;
    return DeviceType.phone;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime, {String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validate phone number format (basic)
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{7,15}$').hasMatch(phone);
  }

  /// Generate random string
  static String generateRandomString(
    int length, {
    bool includeNumbers = true,
    bool includeSymbols = false,
  }) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = r'!@#$%^&*';

    var charset = chars;
    if (includeNumbers) charset += numbers;
    if (includeSymbols) charset += symbols;

    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => charset.codeUnitAt(random.nextInt(charset.length)),
      ),
    );
  }

  /// Clear timezone cache (useful for testing or memory management)
  static void clearTimezoneCache() {
    _timezoneCache.clear();
  }

  static String getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static Future<void> exportAndSharePdf({
    required String endpoint,
    required String filename,
  }) async {
    final bytes = await NetworkUtil().getBytes(endpoint);
    final pdfBytes = Uint8List.fromList(bytes);
    final pdfFileName =
        '${filename}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (kIsWeb) {
      await _sharePdfOnWeb(bytes: pdfBytes, fileName: pdfFileName);
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/$pdfFileName';
    await File(savePath).writeAsBytes(pdfBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(savePath, mimeType: 'application/pdf')],
      ),
    );
  }

  static Future<void> _sharePdfOnWeb({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: fileName,
    );

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          fileNameOverrides: [fileName],
        ),
      );

      if (result.status == ShareResultStatus.unavailable) {
        file_download.downloadBytes(
          bytes: bytes,
          fileName: fileName,
          mimeType: 'application/pdf',
        );
      }
    } catch (_) {
      file_download.downloadBytes(
        bytes: bytes,
        fileName: fileName,
        mimeType: 'application/pdf',
      );
    }
  }

  // Static variable to track last back press across all instances
  static DateTime? _lastBackPressed;

  static void exitApp({
    required BuildContext context,
    required bool didPop,
    required Object? result,
    String? exitMessage,
    Duration? timeWindow,
  }) {
    if (didPop) return;

    final now = DateTime.now();
    final window = timeWindow ?? const Duration(seconds: 2);
    final message = exitMessage ?? 'Press back again to exit';

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > window) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: window,
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  static Future<PRFSupportedPlatform> getCurrentPlatform() async {
    if (Platform.isIOS) {
      return PRFSupportedPlatform.ios;
    } else if (Platform.isAndroid) {
      // Check if this is a Huawei device without Google Play Services
      return await _isHuaweiDevice()
          ? PRFSupportedPlatform.huawei
          : PRFSupportedPlatform.android;
    }
    return PRFSupportedPlatform.unknown;
  }

  static Future<bool> _isHuaweiDevice() async {
    try {
      if (Platform.isAndroid) {
        return _checkHuaweiManufacturer();
      }
      return false;
    } catch (e) {
      Logger().e('Error checking Huawei device: $e');
      return false;
    }
  }

  static Future<bool> _checkHuaweiManufacturer() async {
    try {
      // This is a synchronous check that should work in most cases
      // You can also make this async if needed
      final androidInfo = _deviceInfo.androidInfo;

      // Check common Huawei identifiers
      return await androidInfo
          .then((info) {
            final manufacturer = info.manufacturer.toLowerCase();
            final brand = info.brand.toLowerCase();

            return manufacturer.contains('huawei') ||
                manufacturer.contains('honor') ||
                brand.contains('huawei') ||
                brand.contains('honor');
          })
          .catchError((Object e) {
            Logger().e('Error getting Android info: $e');
            return false;
          });
    } catch (e) {
      return false;
    }
  }

  static String toApiTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static DateTime localDateAndTimeToUtc({
    required DateTime date,
    required String hhmm,
  }) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    return localDateTime.toUtc();
  }

  static String toUtcApiTime(DateTime utcDateTime) {
    final hour = utcDateTime.hour.toString().padLeft(2, '0');
    final minute = utcDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String requiredDefine(String key) {
    switch (key) {
      case DefineKeys.baseDomain:
        return _requiredConstDefine(key, _baseDomainDefine);
      case DefineKeys.socketDomain:
        return _requiredConstDefine(key, _socketDomainDefine);
      case DefineKeys.socketKey:
        return _requiredConstDefine(key, _socketKeyDefine);
      case DefineKeys.azureConnString:
        return _requiredConstDefine(key, _azureConnStringDefine);
      case DefineKeys.appId:
        return _requiredConstDefine(key, _appIdDefine);
      case DefineKeys.appSecret:
        return _requiredConstDefine(key, _appSecretDefine);
      case DefineKeys.hiveEncryptionKey:
        return _requiredConstDefine(key, _hiveEncryptionKeyDefine);
      default:
        throw ArgumentError('Unsupported --dart-define key: $key');
    }
  }

  static void ensureRequiredDefines(Iterable<String> keys) {
    final missingKeys = <String>[];

    for (final key in keys) {
      if (_lookupDefine(key).isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      throw StateError(
        'Missing required --dart-define keys: ${missingKeys.join(', ')}',
      );
    }
  }

  static String _requiredConstDefine(String key, String value) {
    if (value.isEmpty) {
      throw StateError('Missing required --dart-define=$key for production.');
    }
    return value;
  }

  static String _lookupDefine(String key) {
    switch (key) {
      case DefineKeys.baseDomain:
        return _baseDomainDefine;
      case DefineKeys.socketDomain:
        return _socketDomainDefine;
      case DefineKeys.socketKey:
        return _socketKeyDefine;
      case DefineKeys.azureConnString:
        return _azureConnStringDefine;
      case DefineKeys.appId:
        return _appIdDefine;
      case DefineKeys.appSecret:
        return _appSecretDefine;
      case DefineKeys.hiveEncryptionKey:
        return _hiveEncryptionKeyDefine;
      default:
        throw ArgumentError('Unsupported --dart-define key: $key');
    }
  }
}

/// Device type enumeration
enum DeviceType {
  phone,
  tablet,
  desktop,
}
