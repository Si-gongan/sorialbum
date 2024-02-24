import 'package:get_storage/get_storage.dart';

class SearchHistoryManager {
  final GetStorage _storage = GetStorage('search');
  final String _historyKey = 'searchHistory';

  // 검색 기록 저장
  void saveSearchQuery(String query) {
    List<String> history = getSearchHistory();
    history.add(query);
    _storage.write(_historyKey, history);
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
    print(history);
    return history;
  }

  // 검색 기록 삭제
  void clearSearchHistory() {
    _storage.remove(_historyKey);
  }
}
