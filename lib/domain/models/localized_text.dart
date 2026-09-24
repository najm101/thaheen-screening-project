import 'package:equatable/equatable.dart';

final class LocalizedText extends Equatable {
  const LocalizedText({required this.ar, required this.en});

  final String ar;
  final String en;

  String resolve(String languageCode) => languageCode == 'en' ? en : ar;

  Iterable<String> get values => [ar, en];

  @override
  List<Object> get props => [ar, en];
}
