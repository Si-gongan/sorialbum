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
          'sharedImages': [],
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
  static Future<List<String>> storeImages(List<Map<String, dynamic>> imagesData) async {
    String uid = await _getOrCreateUID();

    // WriteBatch 인스턴스 생성
    WriteBatch batch = _firestore.batch();

    try {
      List<String> documentIds = [];

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

        documentIds.add(imageDocRef.id);
      }

      DocumentReference userDocRef = _firestore.collection('User').doc(uid);

      batch.update(userDocRef, {'imageNum': FieldValue.increment(imagesData.length)});

      // Batch 작업을 실행하여 모든 이미지 정보를 한 번에 Firestore에 저장
      await batch.commit();

      return documentIds;
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
  
  // 공유 이미지 기록 저장
  static Future<void> sharedImage(Map<String, dynamic> image) async {
    try {
      await _firestore.collection('Image').doc(image['firestoreId']).update({
        'shared': FieldValue.arrayUnion([{'sharedAt': DateTime.now().localTime}])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // 인터뷰이 연락처 정보 저장
  static Future<void> saveIntervieweeContact(String contact) async {
    String uid = await _getOrCreateUID();

    try {
      await _firestore.collection('User').doc(uid).update({
        'intervieweeContact': contact,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // 사용자 생성 날짜 가져오기
  static Future<DateTime> getUserCreatedAt() async {
    String uid = await _getOrCreateUID();
    try {
      DocumentSnapshot userDocSnapshot =
          await _firestore.collection('User').doc(uid).get();
      return userDocSnapshot.get('createdAt').toDate();
    } catch (e) {
      print(e.toString());
      return DateTime.now().localTime;
    }
  }

  // 초대 코드 생성
  static Future<String> getInvitationCode() async {
    String uid = await _getOrCreateUID();
    String invitationCode = _uuid.v4().substring(0, 6);

    // 이미 생성 되었는지, invitationCode 필드가 존재하는지 확인
    DocumentSnapshot userDocSnapshot =
        await _firestore.collection('User').doc(uid).get();

    try {
      if (userDocSnapshot.get('invitationCode') != null) {
        return userDocSnapshot.get('invitationCode');
      }
    } catch (e) {
      print(e.toString());
    }

    // 없을 경우 신규 생성
    try {
      await _firestore.collection('User').doc(uid).update({
        'invitationCode': invitationCode,
      });
      return invitationCode;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  // 초대한 사용자 목록 추가 by 초대코드
  static Future<bool> addInvitedUser(String invitationCode) async {
    String uid = await _getOrCreateUID();

    // find invitor by invitation code
    QuerySnapshot invitorSnapshot = await _firestore
        .collection('User')
        .where('invitationCode', isEqualTo: invitationCode)
        .get();
    
    if (invitorSnapshot.docs.isEmpty) {
      return false;
    }
    // add invited user at invitor's document
    try {
      await _firestore.collection('User').doc(invitorSnapshot.docs.first.id).update({
        'invitedUsers': FieldValue.arrayUnion([uid])
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // 초대 이벤트 기간 정보 가져오기
  static Future<Map<String, DateTime>> getInvitationEventPeriod() async {
    try {
      DocumentSnapshot eventDocSnapshot = await _firestore
          .collection('Event')
          .where('event_id', isEqualTo: '2024_invitation')
          .get()
          .then((value) => value.docs.first);
      return {
        'startAt': eventDocSnapshot.get('start').toDate(),
        'endAt': eventDocSnapshot.get('end').toDate(),
      };
    } catch (e) {
      print(e.toString());
      return {
        'startAt': DateTime.now().localTime,
        'endAt': DateTime.now().localTime,
      };
    }
  }
}
