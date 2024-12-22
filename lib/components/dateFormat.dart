import 'package:intl/intl.dart'; // Importing the intl package for date formatting

// Function to get a formatted date (yyyy-MM-dd) from the provided date or current date
String getFormattedDateTime({dynamic dateToFormat}) {
  // Check if a specific date is provided for formatting
  if (dateToFormat != null) {
    // Return the formatted date as 'yyyy-MM-dd' if dateToFormat is not null
    return DateFormat('yyyy-MM-dd').format(dateToFormat).toString();
  } else {
    // If no date is provided, format the current date and return it
    return DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  }
}

// Function to get only the year (yyyy) from the provided date or the current year
String getFormattedYear({dynamic year}) {
  // Check if a specific year or date is provided for formatting
  if (year != null) {
    // Return the formatted year (yyyy) from the provided date
    return DateFormat('yyyy').format(year).toString();
  } else {
    // If no date is provided, format and return the current year
    return DateFormat('yyyy').format(DateTime.now()).toString();
  }
}