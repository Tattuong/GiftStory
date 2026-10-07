import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/gift/gift_book.dart';
import '../providers/gift_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/coin_balance_chip.dart';
import '../widgets/gift_chrome.dart';
import 'home/settings_screen.dart';
import 'memory_screen.dart';
import 'person_editor_screen.dart';
import 'person_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    return FtrScaffold(
      extendBody: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  const _UpcomingPage(),
                  const _PeoplePage(),
                  const _IdeasPage(),
                  _MemoriesPage(onAdd: () => _addMemory(context)),
                ],
              ),
            ),
            _Nav(
                index: _tab, onSelect: (index) => setState(() => _tab = index)),
          ],
        ),
      ),
    );
  }

  Future<void> _addMemory(BuildContext context) async {
    final gifts = context.read<GiftProvider>();
    if (gifts.people.isEmpty) return;
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Who is this for?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            for (final person in gifts.people)
              ListTile(
                leading: PersonAvatar(name: person.name, tone: person.tone),
                title: Text(person.name),
                onTap: () => Navigator.pop(context, person.id),
              ),
          ],
        ),
      ),
    );
    if (id == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemoryScreen(personId: id)),
    );
  }
}

class _Nav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _Nav({required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Row(
        children: [
          _item(0, Icons.home_outlined, Icons.home, 'Home'),
          _item(1, Icons.people_outline, Icons.people, 'People'),
          _item(2, Icons.card_giftcard_outlined, Icons.card_giftcard, 'Ideas'),
          _item(3, Icons.menu_book_outlined, Icons.menu_book, 'Memories'),
        ],
      ),
    );
  }

  Widget _item(int i, IconData icon, IconData selected, String label) {
    final on = index == i;
    final color = on ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(i),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(on ? selected : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingPage extends StatefulWidget {
  const _UpcomingPage();

  @override
  State<_UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<_UpcomingPage> {
  var _filter = 0;

  @override
  Widget build(BuildContext context) {
    final gifts = context.watch<GiftProvider>();
    final today = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            const Text('GiftStory',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4)),
            const Spacer(),
            const CoinBalanceChip(variant: CoinChipVariant.header),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const Text('Thoughtful today. Happier tomorrows.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(
          children: [
            _Filter(
                label: 'Upcoming',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0)),
            const SizedBox(width: 8),
            _Filter(
                label: 'All People',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1)),
            const SizedBox(width: 8),
            _Filter(
                label: 'Past Occasions',
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2)),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _filter == 0
              ? 'Upcoming Occasions'
              : _filter == 1
                  ? 'All People'
                  : 'Past Occasions',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (gifts.people.isEmpty)
          const Text('Add someone you like to give gifts to.',
              style: TextStyle(color: AppColors.textSecondary)),
        if (_filter == 1)
          for (final person in gifts.people) ...[
            _PersonRow(person: person),
            const SizedBox(height: 12),
          ]
        else
          for (final hit in _filter == 0
              ? GiftEngine.upcoming(gifts.book, today)
              : GiftEngine.past(gifts.book, today)) ...[
            _OccasionRow(hit: hit, past: _filter == 2),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OccasionRow extends StatelessWidget {
  final OccasionHit hit;
  final bool past;

  const _OccasionRow({required this.hit, required this.past});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, y').format(hit.date);
    return GiftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => PersonScreen(personId: hit.person.id)),
      ),
      child: Row(
        children: [
          PersonAvatar(name: hit.person.name, tone: hit.person.tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(hit.person.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    DayBadge(
                        label:
                            past ? 'Passed' : GiftEngine.countdown(hit.days)),
                  ],
                ),
                Text(hit.occasion.label,
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(date,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD7C4C8)),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final Person person;

  const _PersonRow({required this.person});

  @override
  Widget build(BuildContext context) {
    final next = person.occasions.isEmpty
        ? null
        : GiftEngine.nextOn(person.occasions.first, DateTime.now());
    return GiftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PersonScreen(personId: person.id)),
      ),
      child: Row(
        children: [
          PersonAvatar(name: person.name, tone: person.tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                Text(
                  next == null
                      ? 'No date yet'
                      : '${person.occasions.first.label} · ${DateFormat('MMM d').format(next)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD7C4C8)),
        ],
      ),
    );
  }
}

class _PeoplePage extends StatelessWidget {
  const _PeoplePage();

  @override
  Widget build(BuildContext context) {
    final gifts = context.watch<GiftProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('People',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Preferences, dates, and the gifts you remember.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        for (final person in gifts.people) ...[
          _PersonRow(person: person),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => _add(context),
          icon: const Icon(Icons.add),
          label: const Text('Add person'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final gifts = context.read<GiftProvider>();
    final shop = context.read<ShopProvider>();
    if (!gifts.canAddPerson(shop.hasPro)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unlock GiftStory Pro to add more people.')));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PersonEditorScreen()),
    );
  }
}

class _IdeasPage extends StatelessWidget {
  const _IdeasPage();

  @override
  Widget build(BuildContext context) {
    final gifts = context.watch<GiftProvider>();
    final ideas = [
      for (final gift in gifts.gifts)
        if (!gift.given) gift,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Gift ideas',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Keep them until the right day, then mark them given.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (ideas.isEmpty)
          const Text('No open ideas yet.',
              style: TextStyle(color: AppColors.textSecondary)),
        for (final idea in ideas) ...[
          _IdeaRow(idea: idea, person: gifts.personById(idea.personId)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _IdeaRow extends StatelessWidget {
  final GiftItem idea;
  final Person? person;

  const _IdeaRow({required this.idea, required this.person});

  @override
  Widget build(BuildContext context) {
    return GiftCard(
      onTap: person == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PersonScreen(
                    personId: person!.id,
                    initialTab: 1,
                  ),
                ),
              ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: GiftPicture(title: idea.title, height: 64),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(idea.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  person == null ? idea.note : '${person!.name} · ${idea.note}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MemoriesPage extends StatelessWidget {
  final VoidCallback onAdd;

  const _MemoriesPage({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final gifts = context.watch<GiftProvider>();
    final memories = GiftEngine.allMemories(gifts.book);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Memories',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Little gifts, big stories.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (memories.isEmpty)
          const Text('Mark an idea as given to start the timeline.',
              style: TextStyle(color: AppColors.textSecondary)),
        for (final memory in memories) ...[
          _MemoryRow(
            memory: memory,
            person: gifts.personById(memory.personId),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        WineButton(label: 'Add memory', icon: Icons.add, onPressed: onAdd),
      ],
    );
  }
}

class _MemoryRow extends StatelessWidget {
  final GiftItem memory;
  final Person? person;

  const _MemoryRow({required this.memory, required this.person});

  @override
  Widget build(BuildContext context) {
    final when = memory.givenOn == null
        ? ''
        : DateFormat('MMM y').format(memory.givenOn!);
    return GiftCard(
      onTap: person == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PersonScreen(personId: person!.id, initialTab: 2),
                ),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(when,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(memory.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          if (person != null)
            Text(person!.name,
                style: const TextStyle(color: AppColors.textSecondary)),
          if (memory.memory.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(memory.memory,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
