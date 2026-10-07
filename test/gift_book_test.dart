import 'package:flutter_test/flutter_test.dart';
import 'package:giftstory/core/gift/demo_seed.dart';
import 'package:giftstory/core/gift/gift_book.dart';

void main() {
  final today = DateTime(2026, 10, 6);

  test('next birthday stays this year when it is still ahead', () {
    const birthday = Occasion(id: 'b', label: 'Birthday', month: 10, day: 12);
    expect(GiftEngine.nextOn(birthday, today), DateTime(2026, 10, 12));
    expect(GiftEngine.daysUntil(GiftEngine.nextOn(birthday, today), today), 6);
    expect(GiftEngine.countdown(0), 'Today');
    expect(GiftEngine.countdown(1), 'Tomorrow');
    expect(GiftEngine.countdown(6), 'In 6 days');
  });

  test('a date already passed rolls to next year and clamps short months', () {
    const passed = Occasion(id: 'p', label: 'Birthday', month: 1, day: 2);
    expect(GiftEngine.nextOn(passed, today), DateTime(2027, 1, 2));
    const leap = Occasion(id: 'f', label: 'Birthday', month: 2, day: 31);
    expect(GiftEngine.nextOn(leap, today), DateTime(2027, 2, 28));
  });

  test('upcoming order follows the calendar', () {
    final book = DemoSeed.book();
    final names =
        GiftEngine.upcoming(book, today).map((hit) => hit.person.name).toList();
    expect(names, ['Maya', 'Alex', 'Mom', 'Dad']);
    expect(GiftEngine.upcoming(book, today).first.days, 6);
  });

  test('book round trip and memories newest first', () {
    final book = GiftBook.decode(DemoSeed.book().encode());
    expect(
        book.people.map((person) => person.id), ['maya', 'alex', 'mom', 'dad']);
    final memories = GiftEngine.memoriesFor(book, 'maya');
    expect(memories.map((item) => item.title), ['Ceramic mug', 'Notebook']);
    expect(GiftEngine.ideasFor(book, 'maya'), hasLength(2));
    expect(GiftEngine.freePeople, 4);
  });
}
