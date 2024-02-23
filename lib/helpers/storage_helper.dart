import 'package:get_storage/get_storage.dart';

class SearchHistoryManager {
  final GetStorage _storage = GetStorage();
  final String _historyKey = 'searchHistory';

  // 검색 기록 저장
  void saveSearchQuery(String query) {
    List<String> history = _storage.read(_historyKey) ?? [];
    history.add(query);
    _storage.write(_historyKey, history);
  }

  // 검색 기록 불러오기
  List<String> getSearchHistory() {
    return _storage.read(_historyKey) ?? [];
  }

  // 검색 기록 삭제
  void clearSearchHistory() {
    _storage.remove(_historyKey);
  }
}