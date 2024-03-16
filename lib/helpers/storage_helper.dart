import 'package:get_storage/get_storage.dart';
import 'firestore_helper.dart';
import 'utils.dart';

class SearchHistoryManager {
  final GetStorage _storage = GetStorage('search');
  final String _historyKey = 'searchHistory';

  // 검색 기록 저장
  void saveSearchQuery(String query) {
    List<String> history = getSearchHistory();
    history.add(query);
    _storage.write(_historyKey, history);
    FirestoreHelper.addKeywordSearch(query);
  }

  // 검색 기록 불러오기
  List<String> getSearchHistory() {
    // _storage에서 읽어온 값을 List<dynamic>으로 처리
    var historyDynamic = _storage.read<List>(_historyKey);
    // List<dynamic>을 List<String>으로 변환
    List<String> history = [];

    if (historyDynamic != null) {
      // dynamic 리스트의 각 요소를 String으로 변환하여 새 리스트에 추가
      history = historyDynamic.map((item) => item.toString()).toList();
    }
    return history;
  }

  // 검색 기록 삭제
  void clearSearchHistory() {
    _storage.remove(_historyKey);
  }
}

class TicketManager {
  static final GetStorage _box = GetStorage('ticket');
  static const String _ticketKey = 'tickets';
  static const String _lastUpdateKey = 'lastUpdate';

  static int get defaultTickets => 10;

  // 현재 이용권 개수를 불러옵니다.
  static int get currentTickets {
    _resetTicketsIfNeeded();
    return _box.read(_ticketKey) ?? defaultTickets;
  }

  // 이용권 개수를 업데이트합니다.
  static void useTicket() {
    int current = currentTickets;
    if (current > 0) {
      _box.write(_ticketKey, current - 1);
      _box.write(_lastUpdateKey, DateTime.now().localTime.toString());
    }
    FirestoreHelper.useTicket();
  }

  // 자정에 이용권 개수를 초기화하는 로직을 구현합니다.
  static void _resetTicketsIfNeeded() {
    DateTime now = DateTime.now().localTime;
    String? lastUpdateString = _box.read(_lastUpdateKey);
    DateTime lastUpdate = lastUpdateString != null
        ? DateTime.parse(lastUpdateString)
        : DateTime.now();

    if (lastUpdate.day != now.day ||
        lastUpdate.month != now.month ||
        lastUpdate.year != now.year) {
      _box.write(_ticketKey, defaultTickets);
      _box.write(_lastUpdateKey, now.toString());
    }
  }
}
