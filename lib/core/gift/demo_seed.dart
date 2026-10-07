import 'gift_book.dart';

class DemoSeed {
  DemoSeed._();

  static GiftBook book() {
    const maya = Person(
      id: 'maya',
      name: 'Maya',
      bio: 'A kind soul with big dreams and a love for the little things.',
      tone: 0,
      likes: [
        'Handmade',
        'Cozy home',
        'Stationery',
        'Tea & coffee',
        'Minimal style',
        'Meaningful',
      ],
      budgetMin: 30,
      budgetMax: 50,
      occasions: [
        Occasion(id: 'maya-bday', label: 'Birthday', month: 10, day: 12),
      ],
    );
    const alex = Person(
      id: 'alex',
      name: 'Alex',
      bio: 'Always up for a walk and a good story.',
      tone: 1,
      likes: ['Books', 'Outdoors', 'Coffee'],
      budgetMin: 20,
      budgetMax: 40,
      occasions: [
        Occasion(id: 'alex-bday', label: 'Birthday', month: 11, day: 3),
      ],
    );
    const mom = Person(
      id: 'mom',
      name: 'Mom',
      bio: 'Keeps the family table warm.',
      tone: 2,
      likes: ['Cooking', 'Scarves', 'Flowers'],
      budgetMin: 25,
      budgetMax: 60,
      occasions: [
        Occasion(id: 'mom-bday', label: 'Birthday', month: 11, day: 28),
      ],
    );
    const dad = Person(
      id: 'dad',
      name: 'Dad',
      bio: 'Quiet jokes and strong coffee.',
      tone: 3,
      likes: ['Tools', 'Jazz', 'Coffee'],
      budgetMin: 20,
      budgetMax: 45,
      occasions: [
        Occasion(id: 'dad-bday', label: 'Birthday', month: 12, day: 14),
      ],
    );
    final gifts = [
      const GiftItem(
        id: 'maya-mug-idea',
        personId: 'maya',
        title: 'Handmade mug',
        note: 'Cozy, personal and useful.',
        given: false,
        givenOn: null,
        memory: '',
        photoName: null,
      ),
      const GiftItem(
        id: 'maya-notebook-idea',
        personId: 'maya',
        title: 'Notebook',
        note: 'Perfect for her big ideas.',
        given: false,
        givenOn: null,
        memory: '',
        photoName: null,
      ),
      GiftItem(
        id: 'maya-mug-memory',
        personId: 'maya',
        title: 'Ceramic mug',
        note: '',
        given: true,
        givenOn: DateTime(2025, 9, 1),
        memory:
            'A small reminder to keep believing in brighter days. She loved it!',
        photoName: null,
      ),
      GiftItem(
        id: 'maya-notebook-memory',
        personId: 'maya',
        title: 'Notebook',
        note: '',
        given: true,
        givenOn: DateTime(2024, 12, 1),
        memory: 'For all her ideas and dreams in the year ahead.',
        photoName: null,
      ),
      const GiftItem(
        id: 'alex-book',
        personId: 'alex',
        title: 'Paperback novel',
        note: 'Something he can take on a walk.',
        given: false,
        givenOn: null,
        memory: '',
        photoName: null,
      ),
    ];
    return GiftBook(
      people: const [maya, alex, mom, dad],
      gifts: gifts,
    );
  }
}
