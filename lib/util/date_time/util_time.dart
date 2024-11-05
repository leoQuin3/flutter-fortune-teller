// -----------------------------------------------------------------------
// Filename: util_time.dart
// Original Author: Dan Grissom
// Creation Date: 6/11/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains utility methods for date/time-related
//              needs.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:intl/intl.dart';

// App relative file imports

//////////////////////////////////////////////////////////////////////////
// Enums
//////////////////////////////////////////////////////////////////////////
// Enum definition for time categories
enum TimeCategory {
  // Enum definition
  OLDER,
  LAST_WEEK,
  EARLIER_THIS_WEEK,
  YESTERDAY,
  TODAY,
  TOMORROW,
  LATER_THIS_WEEK,
  FUTURE,
  UNKNOWN;

  // Override toString method
  @override
  String toString() {
    if (this == TimeCategory.OLDER) return "Older";
    if (this == TimeCategory.LAST_WEEK) return "Last Week";
    if (this == TimeCategory.EARLIER_THIS_WEEK) return "Earlier This Week";
    if (this == TimeCategory.YESTERDAY) return "Yesterday";
    if (this == TimeCategory.TODAY) return "Today";
    if (this == TimeCategory.TOMORROW) return "Tomorrow";
    if (this == TimeCategory.LATER_THIS_WEEK) return "Later This Week";
    if (this == TimeCategory.FUTURE) return "Future";
    return "Unknown";
  }
}

//////////////////////////////////////////////////////////////////////////
// Class definition (Static methods only)
//////////////////////////////////////////////////////////////////////////
class UtilTime {
  ////////////////////////////////////////////////////////////////
  // This method takes in an epoch timestamp, compares it to the
  // current time, and returns a string representing the seconds,
  // minutes, hours, days, or months since the timestamp.
  ////////////////////////////////////////////////////////////////
  static String timeSinceString(DateTime timestamp) {
    // Get current time
    DateTime now = DateTime.now();

    // Get difference between now and timestamp
    Duration difference = now.difference(timestamp);

    // Return string based on difference
    if (difference.inSeconds < 1) return "now";
    if (difference.inMinutes < 1) return "${difference.inSeconds}s";
    if (difference.inHours < 1) return "${difference.inMinutes}m";
    if (difference.inDays < 1) return "${difference.inHours}h";
    if (difference.inDays < 30) return "${difference.inDays}d";
    if (difference.inDays < 365) return "${difference.inDays ~/ 30}months";
    return "${difference.inDays ~/ 365}yrs ago";
  }

  ////////////////////////////////////////////////////////////////
  // Function takes in a DateTime and prints out the time in a
  // readable format (HH:mm:ss AM/PM)
  ////////////////////////////////////////////////////////////////
  static String formatToTimeOfDay(DateTime time) {
    return DateFormat('h:mm:ss a').format(time);
  }

  ////////////////////////////////////////////////////////////////
  //Function to convert seconds to a time string
  ////////////////////////////////////////////////////////////////
  static String secondsToTimeString(int seconds) {
    //Convert seconds to hours, minutes, and seconds
    int hours = (seconds / 3600).truncate();
    int minutes = ((seconds % 3600) / 60).truncate();
    int secs = (seconds % 60).truncate();

    // Return formatted string
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs.toString().padLeft(2, '0')}s';
    } else {
      return '${minutes}m ${secs.toString().padLeft(2, '0')}s';
    }
  }

  ////////////////////////////////////////////////////////////////
  // Given a start time, generates an end time to the next
  // 30 minute or hour mark that is at least 15 minutes from the
  // start time.
  ////////////////////////////////////////////////////////////////
  static DateTime generateAutoEndTime(DateTime startTime) {
    // Initialize end time
    DateTime endTime = startTime;

    // If the start time is before the 30 minute mark, set the end time to
    // the 30 minute mark, otherwise set it to the next hour
    if (startTime.minute < 30) {
      endTime = DateTime(startTime.year, startTime.month, startTime.day, startTime.hour, 30);
    } else {
      endTime = DateTime(startTime.year, startTime.month, startTime.day, startTime.hour + 1, 0);
    }

    // If the end time is less than 15 (14) minutes from the start time, add 30 minutes
    if (endTime.difference(startTime).inMinutes < 14) {
      endTime = endTime.add(const Duration(minutes: 30));
    }

    // Return the end time
    return endTime;
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a DateTime as a UTC time, converts it to local time
  // (if dictated by the parameter) and returns a string in the
  // format "August 30, 2024 3:00 PM PDT"
  ////////////////////////////////////////////////////////////////
  static String utcToString(DateTime? utcTime, {bool convertToLocal = false}) {
    // If the time is null, return an empty string
    if (utcTime == null) return 'Unknown Date/Time';

    // Convert to local time (if requested) and get timezone abbreviation
    DateTime time = convertToLocal ? utcTime.toLocal() : utcTime;
    String timeZone = time.timeZoneName;

    // Return formatted string
    DateFormat dateFormat = DateFormat('MMMM d, yyyy h:mm a');
    return dateFormat.format(time) + ' $timeZone';
  }

  ////////////////////////////////////////////////////////////////
  // Takes in a DateTime as a UTC time, converts it to local time
  // (if dictated by the parameter) and returns a string in the
  // format "August 30, 2024 3:00 PM PDT (2 hrs 30 mins)"
  ////////////////////////////////////////////////////////////////
  static String utcAndLengthToString(DateTime? utcTimeStart, DateTime? utcTimeEnd, {bool convertToLocal = false}) {
    // If either time is null, handle appropriately
    if (utcTimeStart == null) return 'Unknown Date/Time';
    if (utcTimeEnd == null) return utcToString(utcTimeStart, convertToLocal: convertToLocal);

    // Convert to local time (if requested) and get timezone abbreviation
    DateTime timeStart = convertToLocal ? utcTimeStart.toLocal() : utcTimeStart;
    DateTime timeEnd = convertToLocal ? utcTimeEnd.toLocal() : utcTimeEnd;
    String timeZone = timeStart.timeZoneName;

    // Get duration (hrs and mins)
    Duration duration = timeEnd.difference(timeStart);
    int hours = duration.inHours;
    int mins = duration.inMinutes.remainder(60);
    String hrsStr = hours > 0 ? ('$hours hr${hours > 1 ? "s" : ""}') : '';
    String minsStr = mins > 0 ? ('$mins min${mins > 1 ? "s" : ""}') : '';
    String hrsMinsStr = (hours > 0 && mins > 0) ? '$hrsStr $minsStr' : (hours > 0 ? '$hrsStr' : '$minsStr');
    if (hrsMinsStr.trim().isEmpty) hrsMinsStr = '0 mins';

    // Return formatted string
    DateFormat dateFormat = DateFormat('MM/dd/yy h:mm a');
    return dateFormat.format(timeStart) + ' $timeZone ($hrsMinsStr)';
  }

  ////////////////////////////////////////////////////////////////
  // Takes in two DateTimes in UTC time, converts them to local time
  // (if dictated by the parameter) and returns a string in the
  // format "August 30, 2024 3:00 - 4:15 PM PDT"
  ////////////////////////////////////////////////////////////////
  static String utcRangeToString(DateTime? utcTimeStart, DateTime? utcTimeEnd, {bool convertToLocal = false}) {
    // If either time is null, handle appropriately
    if (utcTimeStart == null) return 'Unknown Date/Time';
    if (utcTimeEnd == null) return utcToString(utcTimeStart, convertToLocal: convertToLocal);

    // Convert to local time (if requested) and get timezone abbreviation
    DateTime timeStart = convertToLocal ? utcTimeStart.toLocal() : utcTimeStart;
    DateTime timeEnd = convertToLocal ? utcTimeEnd.toLocal() : utcTimeEnd;
    String timeZone = timeStart.timeZoneName;

    // Create date and time formats
    DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    DateFormat timeFormatNoAmPm = DateFormat('h:mm');
    DateFormat timeFormatWithAmPm = DateFormat('h:mm a');

    // Get duration (hrs and mins)
    Duration duration = timeEnd.difference(timeStart);
    if (duration.inMinutes > 0) {
      return "${dateFormat.format(timeStart)} ${timeFormatNoAmPm.format(timeStart)} - ${timeFormatWithAmPm.format(timeEnd)} $timeZone";
    } else {
      return "${dateFormat.format(timeStart)} ${timeFormatWithAmPm.format(timeStart)} $timeZone";
    }
  }

  ////////////////////////////////////////////////////////////////
  // Based on a given time, computes relative dates
  ////////////////////////////////////////////////////////////////
  static DateTime getStartOfWeek(DateTime now) {
    int numDaysFromSunday = now.weekday % DateTime.daysPerWeek;
    DateTime startOfWeek = now.subtract(Duration(days: numDaysFromSunday));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // AppLogger.debug("Start of week: $startOfWeek");
    return startOfWeek;
  }

  static DateTime getStartOfLastWeek(DateTime now) {
    DateTime startOfWeek = getStartOfWeek(now);
    DateTime startOfLastWeek = startOfWeek.subtract(Duration(days: DateTime.daysPerWeek));
    startOfLastWeek = DateTime(startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day);
    // AppLogger.debug("Start of last week: $startOfLastWeek");
    return startOfLastWeek;
  }

  static DateTime getEndOfWeek(DateTime now) {
    int numDaysTillSaturday = DateTime.daysPerWeek - (now.weekday % DateTime.daysPerWeek) - 1;
    DateTime endOfWeek = now.add(Duration(days: numDaysTillSaturday));
    endOfWeek = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999);
    // AppLogger.debug("End of week: $endOfWeek");
    return endOfWeek;
  }

  static DateTime getStartOfYesterday(DateTime now) {
    DateTime startOfYesterday = now.subtract(Duration(days: 1));
    startOfYesterday = DateTime(startOfYesterday.year, startOfYesterday.month, startOfYesterday.day);
    // AppLogger.debug("Start of yesterday: $startOfYesterday");
    return startOfYesterday;
  }

  static DateTime getStartOfToday(DateTime now) {
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    // AppLogger.debug("Start of today: $startOfToday");
    return startOfToday;
  }

  static DateTime getStartOfTomorrow(DateTime now) {
    DateTime startOfTomorrow = now.add(Duration(days: 1));
    startOfTomorrow = DateTime(startOfTomorrow.year, startOfTomorrow.month, startOfTomorrow.day);
    // AppLogger.debug("Start of tomorrow: $startOfTomorrow");
    return startOfTomorrow;
  }

  static DateTime getEndOfTomorrow(DateTime now) {
    DateTime endOfTomorrow = now.add(Duration(days: 1));
    endOfTomorrow = DateTime(endOfTomorrow.year, endOfTomorrow.month, endOfTomorrow.day, 23, 59, 59, 999);
    // AppLogger.debug("End of tomorrow: $endOfTomorrow");
    return endOfTomorrow;
  }

  ////////////////////////////////////////////////////////////////
  // Based on a given time, classifies the time into a category
  ////////////////////////////////////////////////////////////////
  static TimeCategory getTimeCategory(DateTime scheduledStartTime) {
    // Calculate key dates
    DateTime now = DateTime.now();
    DateTime startOfWeek = UtilTime.getStartOfWeek(now);
    DateTime endOfWeek = UtilTime.getEndOfWeek(now);
    DateTime startOfYesterday = UtilTime.getStartOfYesterday(now);
    DateTime startOfToday = UtilTime.getStartOfToday(now);
    DateTime startOfTomorrow = UtilTime.getStartOfTomorrow(now);
    DateTime endOfTomorrow = UtilTime.getEndOfTomorrow(now);
    DateTime startOfLastWeek = UtilTime.getStartOfLastWeek(now);

    // Determine the time category
    if (scheduledStartTime.isAtSameMomentAs(endOfWeek) || scheduledStartTime.isAfter(endOfWeek)) {
      return TimeCategory.FUTURE;
    } else if (scheduledStartTime.isAtSameMomentAs(endOfTomorrow) || scheduledStartTime.isAfter(endOfTomorrow)) {
      return TimeCategory.LATER_THIS_WEEK;
    } else if (scheduledStartTime.isAtSameMomentAs(startOfTomorrow) || scheduledStartTime.isAfter(startOfTomorrow)) {
      return TimeCategory.TOMORROW;
    } else if (scheduledStartTime.isAtSameMomentAs(startOfToday) || scheduledStartTime.isAfter(startOfToday)) {
      return TimeCategory.TODAY;
    } else if (scheduledStartTime.isAtSameMomentAs(startOfYesterday) || scheduledStartTime.isAfter(startOfYesterday)) {
      return TimeCategory.YESTERDAY;
    } else if (scheduledStartTime.isAtSameMomentAs(startOfWeek) || scheduledStartTime.isAfter(startOfWeek)) {
      return TimeCategory.EARLIER_THIS_WEEK;
    } else if (scheduledStartTime.isAtSameMomentAs(startOfLastWeek) || scheduledStartTime.isAfter(startOfLastWeek)) {
      return TimeCategory.LAST_WEEK;
    } else if (scheduledStartTime.isBefore(startOfLastWeek)) {
      return TimeCategory.OLDER;
    } else {
      return TimeCategory.UNKNOWN;
    }
  }
}
