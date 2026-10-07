import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/gift_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gift_chrome.dart';

class PersonEditorScreen extends StatefulWidget {
  const PersonEditorScreen({super.key});

  @override
  State<PersonEditorScreen> createState() => _PersonEditorScreenState();
}

class _PersonEditorScreenState extends State<PersonEditorScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  var _month = DateTime.now().month;
  var _day = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FtrScaffold(
      appBar: AppBar(title: const Text('New person')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _bio,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'A short note'),
          ),
          const SizedBox(height: 16),
          const Text('Birthday', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _month,
                  decoration: const InputDecoration(labelText: 'Month'),
                  items: [
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(value: month, child: Text('$month')),
                  ],
                  onChanged: (value) =>
                      setState(() => _month = value ?? _month),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _day,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: [
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('$day')),
                  ],
                  onChanged: (value) => setState(() => _day = value ?? _day),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WineButton(
            label: 'Save',
            icon: Icons.check_rounded,
            onPressed: _name.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final gifts = context.read<GiftProvider>();
    final shop = context.read<ShopProvider>();
    final created = await gifts.createPerson(
      name: _name.text,
      bio: _bio.text,
      month: _month,
      day: _day,
      hasPro: shop.hasPro,
    );
    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unlock GiftStory Pro to add more people.')));
      return;
    }
    Navigator.pop(context);
  }
}

class LikeEditor extends StatefulWidget {
  final List<String> likes;

  const LikeEditor({super.key, required this.likes});

  @override
  State<LikeEditor> createState() => _LikeEditorState();
}

class _LikeEditorState extends State<LikeEditor> {
  late final List<String> _likes = [...widget.likes];
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preferences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final like in _likes)
                InputChip(
                  label: Text(like),
                  onDeleted: () => setState(() => _likes.remove(like)),
                ),
            ],
          ),
          TextField(
            controller: _text,
            decoration: const InputDecoration(labelText: 'Add a preference'),
            onSubmitted: _add,
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            _add(_text.text);
            Navigator.pop(context, _likes);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _add(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _likes.contains(text)) return;
    setState(() {
      _likes.add(text);
      _text.clear();
    });
  }
}
