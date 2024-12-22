import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package for database operations

// Function to get the last ID from a specific Firestore collection.
Future<int?> getLastID({
  required String collectionName, // The name of the Firestore collection
  required String
      primaryKey, // The field that serves as the primary key for ordering
}) async {
  try {
    // Getting an instance of Firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    // Query the collection, order by the primary key in descending order, and limit to the last record
    QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
        .collection(collectionName)
        .orderBy(primaryKey,
            descending: true) // Order by the primary key in descending order
        .limit(1) // Limit to 1 document (highest ID)
        .get();

    // Check if there are documents in the snapshot
    if (snapshot.docs.isNotEmpty) {
      // Get the primary key value as a String
      final dynamic idValue = snapshot.docs.first[primaryKey];

      // Ensure the value is a String and can be parsed into an integer
      if (idValue is String && int.tryParse(idValue) != null) {
        return int.parse(idValue); // Return the parsed integer
      } else if (idValue is int) {
        return idValue; // If it's already an integer, return it
      }
    }

    return null; // Return null if no valid ID is found or documents are empty
  } catch (e) {
    return null; // Return null in case of error
  }
}
