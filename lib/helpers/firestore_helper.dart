import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:get_storage/get_storage.dart';
import 'utils.dart';

class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GetStorage _storage = GetStorage();
  static final Uuid _uuid = Uuid();

  static Future<String> _getOrCreateUID() async {
    String? uid = _storage.read('userUID');

    if (uid == null) {
      uid = _uuid.v4();
      _storage.write('userUID', uid);
    }

    return uid;
  }

  // 사용자 문서 생성 또는 확인
  static Future<void> createUserDocumentIfNeeded() async {
    String uid = await _getOrCreateUID();

    // 사용자 문서가 이미 존재하는지 확인
    DocumentSnapshot userDocSnapshot =
        await _firestore.collection('User').doc(uid).get();
    if (!userDocSnapshot.exists) {
      // 사용자 문서가 없으면 새로 생성
      try {
        await _firestore.collection('User').doc(uid).set({
          'id': uid,
          'imageNum': 0,
          'keywords': [],
          'tickets': [],
          'createdAt': DateTime.now().localTime,
        });
        print("새 사용자 문서 생성됨: $uid");
      } catch (e) {
        print(e.toString());
      }
    } else {
      print("사용자 문서 이미 존재: $uid");
    }
  }

  // 여러 이미지 정보 저장
  static Future<void> storeImages(List<Map<String, dynamic>> imagesData) async {
    String uid = await _getOrCreateUID();

    // WriteBatch 인스턴스 생성
    WriteBatch batch = _firestore.batch();

    try {
      // 각 이미지 데이터에 대해 반복
      for (var imageData in imagesData) {
        // 새로운 문서 ID를 생성
        DocumentReference imageDocRef = _firestore.collection('Image').doc();

        // Batch에 set 작업 추가
        batch.set(imageDocRef, {
          'userId': uid,
          'url': imageData['imageUrl'],
          'caption': imageData['caption'],
          'tags': imageData['generalTags']?.split(','),
          'description': imageData['description'],
          'ocr': imageData['ocr'],
          'storedAt': DateTime.parse(imageData['storedAt']),
        });
      }

      DocumentReference userDocRef = _firestore.collection('User').doc(uid);

      batch.update(userDocRef, {'imageNum': FieldValue.increment(imagesData.length)});

      // Batch 작업을 실행하여 모든 이미지 정보를 한 번에 Firestore에 저장
      await batch.commit();
    } catch (e) {
      print(e.toString());
      throw e; // 에러 처리 또는 추가 로직
    }
  }

  // 키워드 검색 기록 저장
  static Future<void> addKeywordSearch(String keyword) async {
    String uid = await _getOrCreateUID();

    try {
      await _firestore.collection('User').doc(uid).update({
        'keywords': FieldValue.arrayUnion([
          {'keyword': keyword, 'createdAt': DateTime.now().localTime}
        ]),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // 캡션 생성 이용권 사용 기록 저장
  static Future<void> useTicket() async {
    String uid = await _getOrCreateUID();

    try {
      await _firestore.collection('User').doc(uid).update({
        'tickets': FieldValue.arrayUnion([
          {'createdAt': DateTime.now().localTime}
        ]),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // // 하루에 사용 가능한 티켓 수 검사 (하루 10개 제한)
  // Future<bool> canUseTicket(String userId) async {
  //   try {
  //     var userDoc = await _firestore.collection('User').doc(userId).get();
  //     var tickets = userDoc.data()?['tickets'] ?? [];
  //     int todayTicketCount = tickets.where((ticket) {
  //       DateTime createdAt = (ticket['createdAt'] as Timestamp).toDate();
  //       return createdAt.day == DateTime.now().day &&
  //           createdAt.month == DateTime.now().month &&
  //           createdAt.year == DateTime.now().year;
  //     }).length;
  //     return todayTicketCount < 10;
  //   } catch (e) {
  //     print(e.toString());
  //     return false;
  //   }
  // }
}
