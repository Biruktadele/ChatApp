import '../../domain/entities/sugession.dart';

class SugessionModeal extends Suggestions {
  SugessionModeal({
    String suggestion1 = '',
    String suggestion2 = '',
    String suggestion3 = '',
  }) : super(
          suggestion1: suggestion1,
          suggestion2: suggestion2,
          suggestion3: suggestion3,
        );
    factory SugessionModeal.fromSocketData(Map<String, dynamic> json) {
      return SugessionModeal(
        suggestion1: json['suggestion1'] as String? ?? '',
        suggestion2: json['suggestion2'] as String? ?? '',
        suggestion3: json['suggestion3'] as String? ?? '',
      );
    }
  Map<String, dynamic> toJson() {
    return {
      'suggestion1': suggestion1,
      'suggestion2': suggestion2,
      'suggestion3': suggestion3,
    };
  }
  factory SugessionModeal.fromEntity(Suggestions suggestions) {
    return SugessionModeal(
      suggestion1: suggestions.suggestion1,
      suggestion2: suggestions.suggestion2,
      suggestion3: suggestions.suggestion3,
    );
  }
  Suggestions toEntity() {
    return Suggestions(
      suggestion1: suggestion1,
      suggestion2: suggestion2,
      suggestion3: suggestion3,
    );
  }

  
}