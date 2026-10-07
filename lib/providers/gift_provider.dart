import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../core/gift/gift_book.dart';
import '../core/services/gift_reminder.dart';
import '../core/services/storage_service.dart';

class GiftProvider extends ChangeNotifier {
  static const _bookKey = 'gs_gifts';
  static const _remindKey = 'gs_reminders';
  static const _demoIds = {'maya', 'alex', 'mom', 'dad'};

  List<Person> people = [];
  List<GiftItem> gifts = [];
  var reminders = true;
  var _seq = 0;

  GiftBook get book => GiftBook(people: people, gifts: gifts);

  Future<void> init() async {
    reminders = await StorageService.instance.getBool(_remindKey) ?? true;
    final raw = await StorageService.instance.getString(_bookKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final saved = GiftBook.decode(raw);
        people = saved.people;
        gifts = saved.gifts;
      } catch (_) {
        await StorageService.instance.remove(_bookKey);
      }
    }
    final keptPeople = [
      for (final person in people)
        if (!_demoIds.contains(person.id)) person,
    ];
    final keptGifts = [
      for (final gift in gifts)
        if (!_demoIds.contains(gift.personId)) gift,
    ];
    if (keptPeople.length != people.length || keptGifts.length != gifts.length) {
      people = keptPeople;
      gifts = keptGifts;
      await _save();
    }
    notifyListeners();
    await GiftReminder.sync(book, enabled: reminders);
  }

  Person? personById(String id) {
    for (final person in people) {
      if (person.id == id) return person;
    }
    return null;
  }

  bool canAddPerson(bool hasPro) =>
      hasPro || people.length < GiftEngine.freePeople;

  Future<Person?> createPerson({
    required String name,
    required String bio,
    required int month,
    required int day,
    required bool hasPro,
  }) async {
    if (!canAddPerson(hasPro)) return null;
    final id = _next('person');
    final person = Person(
      id: id,
      name: name.trim(),
      bio: bio.trim(),
      tone: people.length % 4,
      likes: const [],
      budgetMin: 20,
      budgetMax: 50,
      occasions: [
        Occasion(id: _next('date'), label: 'Birthday', month: month, day: day),
      ],
    );
    people = [...people, person];
    await _commit();
    return person;
  }

  Future<void> updatePerson(Person person) async {
    people = [
      for (final item in people)
        if (item.id == person.id) person else item,
    ];
    await _commit();
  }

  Future<void> deletePerson(String id) async {
    people = [
      for (final person in people)
        if (person.id != id) person,
    ];
    gifts = [
      for (final gift in gifts)
        if (gift.personId != id) gift,
    ];
    await _commit();
  }

  Future<void> setLikes(String personId, List<String> likes) async {
    final person = personById(personId);
    if (person == null) return;
    await updatePerson(person.copyWith(likes: likes));
  }

  Future<void> setBudget(String personId, int min, int max) async {
    final person = personById(personId);
    if (person == null) return;
    final low = min < max ? min : max;
    final high = min < max ? max : min;
    await updatePerson(person.copyWith(budgetMin: low, budgetMax: high));
  }

  Future<void> addOccasion(
      String personId, String label, int month, int day) async {
    final person = personById(personId);
    if (person == null) return;
    await updatePerson(person.copyWith(occasions: [
      ...person.occasions,
      Occasion(id: _next('date'), label: label.trim(), month: month, day: day),
    ]));
  }

  Future<GiftItem?> addIdea({
    required String personId,
    required String title,
    required String note,
  }) async {
    final gift = GiftItem(
      id: _next('gift'),
      personId: personId,
      title: title.trim(),
      note: note.trim(),
      given: false,
      givenOn: null,
      memory: '',
      photoName: null,
    );
    gifts = [...gifts, gift];
    await _commit();
    return gift;
  }

  Future<void> give({
    required String? ideaId,
    required String personId,
    required String title,
    required DateTime givenOn,
    required String memory,
    String? photoName,
  }) async {
    if (ideaId != null) {
      gifts = [
        for (final gift in gifts)
          if (gift.id == ideaId)
            gift.copyWith(
              title: title.trim(),
              given: true,
              givenOn: givenOn,
              memory: memory.trim(),
              photoName: photoName,
            )
          else
            gift,
      ];
    } else {
      gifts = [
        ...gifts,
        GiftItem(
          id: _next('gift'),
          personId: personId,
          title: title.trim(),
          note: '',
          given: true,
          givenOn: givenOn,
          memory: memory.trim(),
          photoName: photoName,
        ),
      ];
    }
    await _commit();
  }

  Future<void> deleteGift(String id) async {
    gifts = [
      for (final gift in gifts)
        if (gift.id != id) gift,
    ];
    await _commit();
  }

  Future<String?> savePhoto(String sourcePath, String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/memories');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    final name = '$id.jpg';
    await File(sourcePath).copy('${folder.path}/$name');
    return name;
  }

  Future<String?> photoPath(String? name) async {
    if (name == null || name.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/memories/$name');
    if (!file.existsSync()) return null;
    return file.path;
  }

  Future<void> setReminders(bool value) async {
    reminders = value;
    await StorageService.instance.saveBool(_remindKey, value);
    notifyListeners();
    await GiftReminder.sync(book, enabled: reminders);
  }

  Future<void> _commit() async {
    await _save();
    notifyListeners();
    await GiftReminder.sync(book, enabled: reminders);
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(_bookKey, book.encode());
  }

  String _next(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';
}
