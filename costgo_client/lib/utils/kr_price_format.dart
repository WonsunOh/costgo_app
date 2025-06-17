import 'package:intl/intl.dart';

String formatPrice(double price, {bool includeSymbol = true, int decimalDigits = 0}) {
  final format = NumberFormat.currency(
    locale: 'ko_KR', // 한국 로케일
    symbol: includeSymbol ? '₩' : '', // 통화 기호 포함 여부
    decimalDigits: decimalDigits, // 소수점 자릿수
  );
  return format.format(price);
}

String formatNumberWithComma(num number) { // double 또는 int 모두 처리 가능
  final format = NumberFormat('#,###');
  return format.format(number);
}