import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/supportRequestModel/supportRequestModel.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitSupportRequest(SupportRequestModel request) async {
    final data = request.toMap();

    data["createdAt"] = FieldValue.serverTimestamp();

    await _firestore.collection("support_requests").add(data);
    ;
  }
}
