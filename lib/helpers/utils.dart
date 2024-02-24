import 'dart:math';
import 'package:timezone/timezone.dart';

double cosineSimilarity(List<double> vec1, List<double> vec2) {
  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  for (int i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    normA += vec1[i] * vec1[i];
    normB += vec2[i] * vec2[i];
  }
  return dotProduct / (sqrt(normA) * sqrt(normB));
}

class DateTimeUtil {
  // 기본 타임존을 Asia/Seoul로 지정
  static String timezone = 'Asia/Seoul';

  // 현지 시간을 한국시간으로 변환할때 사용
  static final korTimeZone = getLocation('Asia/Seoul');
}

extension DateTimeExtension on DateTime {
  DateTime get localTime {
    // 3에서 구한 timezone으로 location정보를 불러온다.
    final location = getLocation(DateTimeUtil.timezone);
    final localTimeZone =
        TZDateTime(location, year, month, day, hour, minute, second);

    // 한국시간만큼 빼기
    final utc = subtract(
      Duration(milliseconds: DateTimeUtil.korTimeZone.currentTimeZone.offset),
    );
    // local timezone의 offset만큼 더해주었다.
    final localTime = utc.add(localTimeZone.timeZoneOffset);

    return localTime;
  }
}
