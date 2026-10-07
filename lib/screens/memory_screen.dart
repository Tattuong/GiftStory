import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/gift/gift_book.dart';
import '../providers/gift_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gift_chrome.dart';

class MemoryScreen extends StatefulWidget {
  final String personId;
  final String? ideaId;

  const MemoryScreen({super.key, required this.personId, this.ideaId});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _title = TextEditingController();
  final _memory = TextEditingController();
  DateTime _date = DateTime.now();
  String? _photoPath;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final idea = widget.ideaId;
    if (idea == null) return;
    final gifts = context.read<GiftProvider>();
    for (final gift in gifts.gifts) {
      if (gift.id == idea) {
        _title.text = gift.title;
        _memory.text = gift.note;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _memory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FtrScaffold(
      appBar: AppBar(
          title: Text(widget.ideaId == null ? 'Add memory' : 'Mark as given')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Gift'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat('MMM d, y').format(_date)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          TextField(
            controller: _memory,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What they thought'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_outlined),
            label: Text(_photoPath == null ? 'Add a photo' : 'Change photo'),
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(File(_photoPath!),
                  height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 20),
          WineButton(
            label: 'Save memory',
            icon: Icons.check_rounded,
            onPressed: _title.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() => _photoPath = file.path);
  }

  Future<void> _save() async {
    final gifts = context.read<GiftProvider>();
    String? photoName;
    if (_photoPath != null) {
      photoName = await gifts.savePhoto(_photoPath!,
          widget.ideaId ?? 'mem-${DateTime.now().microsecondsSinceEpoch}');
    }
    await gifts.give(
      ideaId: widget.ideaId,
      personId: widget.personId,
      title: _title.text,
      givenOn: _date,
      memory: _memory.text,
      photoName: photoName,
    );
    if (mounted) Navigator.pop(context);
  }
}

class IdeaEditor extends StatefulWidget {
  const IdeaEditor({super.key});

  @override
  State<IdeaEditor> createState() => _IdeaEditorState();
}

class _IdeaEditorState extends State<IdeaEditor> {
  final _title = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gift idea'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _note,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Why it fits'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_title.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              GiftItem(
                id: '',
                personId: '',
                title: _title.text.trim(),
                note: _note.text.trim(),
                given: false,
                givenOn: null,
                memory: '',
                photoName: null,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
