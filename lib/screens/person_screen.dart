import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/gift/gift_book.dart';
import '../providers/gift_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gift_chrome.dart';
import 'memory_screen.dart';
import 'person_editor_screen.dart';

class PersonScreen extends StatefulWidget {
  final String personId;
  final int initialTab;

  const PersonScreen({super.key, required this.personId, this.initialTab = 0});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  late var _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final gifts = context.watch<GiftProvider>();
    final person = gifts.personById(widget.personId);
    if (person == null) {
      return const FtrScaffold(
          body: Center(child: Text('This person is gone.')));
    }
    final ideas = GiftEngine.ideasFor(gifts.book, person.id);
    final memories = GiftEngine.memoriesFor(gifts.book, person.id);
    return FtrScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(person.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _menu(value, person),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  if (_tab == 0) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PersonAvatar(
                            name: person.name, tone: person.tone, size: 92),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person.name,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      height: 1.05)),
                              if (person.bio.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(person.bio,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          height: 1.35)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  _Tabs(
                    index: _tab,
                    onSelect: (index) => setState(() => _tab = index),
                  ),
                  const SizedBox(height: 18),
                  if (_tab == 0)
                    _ProfileTab(
                      person: person,
                      ideas: ideas,
                      onSeeAll: () => setState(() => _tab = 1),
                    ),
                  if (_tab == 1) _IdeasTab(person: person, ideas: ideas),
                  if (_tab == 2) _MemoriesTab(memories: memories),
                ],
              ),
            ),
            if (_tab == 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: WineButton(
                  label: 'Add memory',
                  icon: Icons.add,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemoryScreen(personId: person.id),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _menu(String value, Person person) async {
    if (value != 'delete') return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${person.name}?'),
        content: const Text('Ideas and memories for them are removed too.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<GiftProvider>().deletePerson(person.id);
    if (mounted) Navigator.pop(context);
  }
}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _Tabs({required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const labels = ['Profile', 'Gift Ideas', 'Memories'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: index == i ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          index == i ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final Person person;
  final List<GiftItem> ideas;
  final VoidCallback onSeeAll;

  const _ProfileTab({
    required this.person,
    required this.ideas,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final dates = person.occasions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GiftCard(
          onTap: () => _addDate(context),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SoftIcon(icon: Icons.calendar_month_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Key Dates',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    if (dates.isEmpty)
                      const Text('Add a birthday or anniversary',
                          style: TextStyle(color: AppColors.textSecondary))
                    else
                      for (final occasion in dates) ...[
                        Text(occasion.label,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        Text(
                          DateFormat('MMM d, y').format(
                              GiftEngine.nextOn(occasion, DateTime.now())),
                          style: const TextStyle(
                              color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD7C4C8)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionHead(
          icon: Icons.favorite,
          label: 'Preferences',
          action: 'Edit',
          onAction: () => _editLikes(context),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final like in person.likes)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconForLike(like), size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(like,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionHead(
          icon: Icons.payments_outlined,
          label: 'Budget (manually entered)',
          action: 'Edit',
          onAction: () => _editBudget(context),
        ),
        Text(
          '\$${person.budgetMin} – \$${person.budgetMax}',
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 22),
        ),
        const SizedBox(height: 18),
        _SectionHead(
          icon: Icons.lightbulb_outline,
          label: 'Gift Ideas',
          action: 'See all',
          onAction: onSeeAll,
        ),
        if (ideas.isEmpty)
          const Text('Save an idea before the next occasion.',
              style: TextStyle(color: AppColors.textSecondary)),
        if (ideas.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < ideas.take(2).length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _IdeaPreview(idea: ideas[i])),
              ],
            ],
          ),
      ],
    );
  }

  Future<void> _editLikes(BuildContext context) async {
    final next = await showDialog<List<String>>(
      context: context,
      builder: (context) => LikeEditor(likes: person.likes),
    );
    if (next == null || !context.mounted) return;
    await context.read<GiftProvider>().setLikes(person.id, next);
  }

  Future<void> _editBudget(BuildContext context) async {
    final result = await showDialog<(int, int)>(
      context: context,
      builder: (context) => _BudgetDialog(
        min: person.budgetMin,
        max: person.budgetMax,
      ),
    );
    if (result == null || !context.mounted) return;
    await context
        .read<GiftProvider>()
        .setBudget(person.id, result.$1, result.$2);
  }

  Future<void> _addDate(BuildContext context) async {
    final result = await showDialog<(String, int, int)>(
      context: context,
      builder: (context) => const _DateDialog(),
    );
    if (result == null || !context.mounted) return;
    await context
        .read<GiftProvider>()
        .addOccasion(person.id, result.$1, result.$2, result.$3);
  }
}

class _IdeasTab extends StatelessWidget {
  final Person person;
  final List<GiftItem> ideas;

  const _IdeasTab({required this.person, required this.ideas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gift Ideas',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 10),
        if (ideas.isEmpty)
          const Text('Save an idea before the next occasion.',
              style: TextStyle(color: AppColors.textSecondary)),
        for (final idea in ideas) ...[
          GiftCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GiftPicture(title: idea.title, height: 140, showHeart: true),
                const SizedBox(height: 10),
                Text(idea.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                if (idea.note.isNotEmpty)
                  Text(idea.note,
                      style: const TextStyle(color: AppColors.textSecondary)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MemoryScreen(
                          personId: person.id,
                          ideaId: idea.id,
                        ),
                      ),
                    ),
                    child: const Text('Mark as given'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextButton.icon(
          onPressed: () => _add(context),
          icon: const Icon(Icons.add),
          label: const Text('Add idea'),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final draft = await showDialog<GiftItem>(
      context: context,
      builder: (context) => const IdeaEditor(),
    );
    if (draft == null || !context.mounted) return;
    await context.read<GiftProvider>().addIdea(
          personId: person.id,
          title: draft.title,
          note: draft.note,
        );
  }
}

class _MemoriesTab extends StatelessWidget {
  final List<GiftItem> memories;

  const _MemoriesTab({required this.memories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(Icons.card_giftcard, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        const Text('A Timeline of Thoughtful Moments',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.2)),
        const SizedBox(height: 4),
        const Text('Little gifts, big stories.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        if (memories.isEmpty)
          const Text('When you give a gift, keep the story here.',
              style: TextStyle(color: AppColors.textSecondary)),
        for (var i = 0; i < memories.length; i++)
          _MemoryTile(memory: memories[i], featured: i == 0),
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;
  final VoidCallback onAction;

  const _SectionHead({
    required this.icon,
    required this.label,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;

  const _SoftIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }
}

class _IdeaPreview extends StatelessWidget {
  final GiftItem idea;

  const _IdeaPreview({required this.idea});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GiftPicture(title: idea.title, height: 110, showHeart: true),
        const SizedBox(height: 8),
        Text(idea.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        if (idea.note.isNotEmpty)
          Text(idea.note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
      ],
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final GiftItem memory;
  final bool featured;

  const _MemoryTile({required this.memory, required this.featured});

  @override
  Widget build(BuildContext context) {
    final when = memory.givenOn == null
        ? ''
        : DateFormat('MMM y').format(memory.givenOn!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 16,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(width: 2, color: AppColors.coralSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(when,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (featured) ...[
                    _Photo(memory: memory, height: 168),
                    const SizedBox(height: 8),
                    Text(memory.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    if (memory.memory.isNotEmpty)
                      Text(memory.memory,
                          style: const TextStyle(
                              color: AppColors.textSecondary, height: 1.35)),
                  ] else
                    GiftCard(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: _Photo(memory: memory, height: 72),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(memory.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                                if (memory.memory.isNotEmpty)
                                  Text(memory.memory,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final GiftItem memory;
  final double height;

  const _Photo({required this.memory, required this.height});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: context.read<GiftProvider>().photoPath(memory.photoName),
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null) {
          return GiftPicture(title: memory.title, height: height);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(path),
              height: height, width: double.infinity, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  final int min;
  final int max;

  const _BudgetDialog({required this.min, required this.max});

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final _min = TextEditingController(text: '${widget.min}');
  late final _max = TextEditingController(text: '${widget.max}');

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Budget'),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _min,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Min'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final low = int.tryParse(_min.text.trim());
            final high = int.tryParse(_max.text.trim());
            if (low == null || high == null) return;
            Navigator.pop(context, (low, high));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DateDialog extends StatefulWidget {
  const _DateDialog();

  @override
  State<_DateDialog> createState() => _DateDialogState();
}

class _DateDialogState extends State<_DateDialog> {
  final _label = TextEditingController(text: 'Anniversary');
  var _month = 1;
  var _day = 1;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _label,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _month,
                  items: [
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(value: month, child: Text('M$month')),
                  ],
                  onChanged: (value) => setState(() => _month = value ?? 1),
                ),
              ),
              Expanded(
                child: DropdownButton<int>(
                  value: _day,
                  items: [
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('$day')),
                  ],
                  onChanged: (value) => setState(() => _day = value ?? 1),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_label.text.trim().isEmpty) return;
            Navigator.pop(context, (_label.text.trim(), _month, _day));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
