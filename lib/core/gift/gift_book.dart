import 'dart:convert';

class Occasion {
  final String id;
  final String label;
  final int month;
  final int day;

  const Occasion({
    required this.id,
    required this.label,
    required this.month,
    required this.day,
  });

  Occasion copyWith({String? label, int? month, int? day}) => Occasion(
        id: id,
        label: label ?? this.label,
        month: month ?? this.month,
        day: day ?? this.day,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'month': month,
        'day': day,
      };

  factory Occasion.fromJson(Map<String, dynamic> json) => Occasion(
        id: json['id'] as String,
        label: json['label'] as String? ?? 'Birthday',
        month: (json['month'] as num?)?.toInt() ?? 1,
        day: (json['day'] as num?)?.toInt() ?? 1,
      );
}

class Person {
  final String id;
  final String name;
  final String bio;
  final int tone;
  final List<String> likes;
  final int budgetMin;
  final int budgetMax;
  final List<Occasion> occasions;

  const Person({
    required this.id,
    required this.name,
    required this.bio,
    required this.tone,
    required this.likes,
    required this.budgetMin,
    required this.budgetMax,
    required this.occasions,
  });

  Person copyWith({
    String? name,
    String? bio,
    int? tone,
    List<String>? likes,
    int? budgetMin,
    int? budgetMax,
    List<Occasion>? occasions,
  }) =>
      Person(
        id: id,
        name: name ?? this.name,
        bio: bio ?? this.bio,
        tone: tone ?? this.tone,
        likes: likes ?? this.likes,
        budgetMin: budgetMin ?? this.budgetMin,
        budgetMax: budgetMax ?? this.budgetMax,
        occasions: occasions ?? this.occasions,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'tone': tone,
        'likes': likes,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'occasions': occasions.map((item) => item.toJson()).toList(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        tone: (json['tone'] as num?)?.toInt() ?? 0,
        likes: [
          for (final item in json['likes'] as List? ?? []) item.toString(),
        ],
        budgetMin: (json['budgetMin'] as num?)?.toInt() ?? 0,
        budgetMax: (json['budgetMax'] as num?)?.toInt() ?? 0,
        occasions: [
          for (final item in json['occasions'] as List? ?? [])
            Occasion.fromJson(Map<String, dynamic>.from(item as Map)),
        ],
      );
}

class GiftItem {
  final String id;
  final String personId;
  final String title;
  final String note;
  final bool given;
  final DateTime? givenOn;
  final String memory;
  final String? photoName;

  const GiftItem({
    required this.id,
    required this.personId,
    required this.title,
    required this.note,
    required this.given,
    required this.givenOn,
    required this.memory,
    required this.photoName,
  });

  GiftItem copyWith({
    String? title,
    String? note,
    bool? given,
    DateTime? givenOn,
    String? memory,
    String? photoName,
    bool clearPhoto = false,
  }) =>
      GiftItem(
        id: id,
        personId: personId,
        title: title ?? this.title,
        note: note ?? this.note,
        given: given ?? this.given,
        givenOn: givenOn ?? this.givenOn,
        memory: memory ?? this.memory,
        photoName: clearPhoto ? null : (photoName ?? this.photoName),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'personId': personId,
        'title': title,
        'note': note,
        'given': given,
        'givenOn': givenOn?.toIso8601String(),
        'memory': memory,
        'photoName': photoName,
      };

  factory GiftItem.fromJson(Map<String, dynamic> json) => GiftItem(
        id: json['id'] as String,
        personId: json['personId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        note: json['note'] as String? ?? '',
        given: json['given'] as bool? ?? false,
        givenOn: json['givenOn'] == null
            ? null
            : DateTime.tryParse(json['givenOn'] as String),
        memory: json['memory'] as String? ?? '',
        photoName: json['photoName'] as String?,
      );
}

class GiftBook {
  final List<Person> people;
  final List<GiftItem> gifts;

  const GiftBook({required this.people, required this.gifts});

  Map<String, dynamic> toJson() => {
        'people': people.map((person) => person.toJson()).toList(),
        'gifts': gifts.map((gift) => gift.toJson()).toList(),
      };

  String encode() => jsonEncode(toJson());

  factory GiftBook.decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GiftBook(
      people: [
        for (final item in json['people'] as List? ?? [])
          Person.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
      gifts: [
        for (final item in json['gifts'] as List? ?? [])
          GiftItem.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}

class OccasionHit {
  final Person person;
  final Occasion occasion;
  final DateTime date;
  final int days;

  const OccasionHit({
    required this.person,
    required this.occasion,
    required this.date,
    required this.days,
  });
}

class GiftEngine {
  GiftEngine._();

  static const freePeople = 4;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _safe(int year, int month, int day) {
    final last = DateTime(year, month + 1, 0).day;
    final safe = day < 1 ? 1 : (day > last ? last : day);
    return DateTime(year, month, safe);
  }

  static DateTime nextOn(Occasion occasion, DateTime today) {
    final day = dateOnly(today);
    var date = _safe(day.year, occasion.month, occasion.day);
    if (date.isBefore(day)) {
      date = _safe(day.year + 1, occasion.month, occasion.day);
    }
    return date;
  }

  static DateTime previousOn(Occasion occasion, DateTime today) {
    final next = nextOn(occasion, today);
    return _safe(next.year - 1, occasion.month, occasion.day);
  }

  static int daysUntil(DateTime date, DateTime today) =>
      dateOnly(date).difference(dateOnly(today)).inDays;

  static List<OccasionHit> upcoming(GiftBook book, DateTime today) {
    final hits = [
      for (final person in book.people)
        for (final occasion in person.occasions)
          OccasionHit(
            person: person,
            occasion: occasion,
            date: nextOn(occasion, today),
            days: daysUntil(nextOn(occasion, today), today),
          ),
    ]..sort((a, b) {
        final byDay = a.days.compareTo(b.days);
        if (byDay != 0) return byDay;
        return a.person.name.compareTo(b.person.name);
      });
    return hits;
  }

  static List<OccasionHit> past(GiftBook book, DateTime today) {
    final hits = [
      for (final person in book.people)
        for (final occasion in person.occasions)
          OccasionHit(
            person: person,
            occasion: occasion,
            date: previousOn(occasion, today),
            days: daysUntil(previousOn(occasion, today), today),
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return hits;
  }

  static String countdown(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }

  static List<GiftItem> ideasFor(GiftBook book, String personId) => [
        for (final gift in book.gifts)
          if (gift.personId == personId && !gift.given) gift,
      ];

  static List<GiftItem> memoriesFor(GiftBook book, String personId) {
    final items = [
      for (final gift in book.gifts)
        if (gift.personId == personId && gift.given) gift,
    ]..sort((a, b) =>
        (b.givenOn ?? DateTime(1970)).compareTo(a.givenOn ?? DateTime(1970)));
    return items;
  }

  static List<GiftItem> allMemories(GiftBook book) {
    final items = [
      for (final gift in book.gifts)
        if (gift.given) gift,
    ]..sort((a, b) =>
        (b.givenOn ?? DateTime(1970)).compareTo(a.givenOn ?? DateTime(1970)));
    return items;
  }
}
