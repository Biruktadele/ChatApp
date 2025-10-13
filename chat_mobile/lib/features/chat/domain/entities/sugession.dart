import 'package:equatable/equatable.dart';

class Suggestions extends Equatable {
  final String suggestion1;
  final String suggestion2;
  final String suggestion3;

  const Suggestions({required this.suggestion1, required this.suggestion2, required this.suggestion3});

  @override
  List<Object?> get props => [suggestion1, suggestion2, suggestion3];
}

