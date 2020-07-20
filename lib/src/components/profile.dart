import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String title;
  final String keyword;
  final String poster;
  final bool like;
  final DocumentReference reference;

  Profile.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        keyword = map['keyword'],
        poster = map['poster'],
        like = map['like'];

  Profile.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Profile<$title:$keyword>";
}
