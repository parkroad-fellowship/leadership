import 'dart:math';

import 'package:flutter/material.dart'
    show BuildContext, MediaQuery, ScaffoldMessenger, SnackBar, Text;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/slugify.dart' as slugify;
import 'package:leadership/versioning/build_version.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class Misc {
  // Private constructor to prevent instantiation
  Misc._();

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
      return version.length > 7 ? version.substring(0, 7) : version;
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

  static bool userCan(String permission) {
    try {
      final user = getIt<HiveService>().auth.retrieveProfile();
      if (user == null) return false;

      // Cache user permissions for better performance
      final userPermissions = user.roles
          .expand((role) => role.permissions)
          .map((permission) => permission.name)
          .toSet();

      return userPermissions.contains(permission);
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
}

/// Device type enumeration
enum DeviceType {
  phone,
  tablet,
  desktop,
}
