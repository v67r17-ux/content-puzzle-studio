import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import '../models/puzzle.dart';
import '../services/local_store.dart';

final localStoreProvider = Provider<LocalStore>((ref) => LocalStore());
final contentProvider = StateNotifierProvider<ContentController, AsyncValue<List<ContentItem>>>(
  (ref) => ContentController(ref.read(localStoreProvider))..load());
final puzzleProvider = StateNotifierProvider<PuzzleController, AsyncValue<List<Puzzle>>>(
  (ref) => PuzzleController(ref.read(localStoreProvider))..load());

class ContentController extends StateNotifier<AsyncValue<List<ContentItem>>> {
  ContentController(this.store) : super(const AsyncValue.loading());
  final LocalStore store;
  Future<void> load() async { state = AsyncValue.data(await store.loadContent()); }
  Future<void> save(ContentItem item) async {
    final List<ContentItem> list = [...(state.valueOrNull ?? <ContentItem>[])];
    final i = list.indexWhere((x) => x.id == item.id);
    if (i < 0) { list.insert(0, item); } else { list[i] = item; }
    await store.saveContent(list);
    state = AsyncValue.data(list);
  }
  Future<void> delete(String id) async {
    final List<ContentItem> list = [...(state.valueOrNull ?? <ContentItem>[])]..removeWhere((x) => x.id == id);
    await store.saveContent(list); state = AsyncValue.data(list);
  }
}

class PuzzleController extends StateNotifier<AsyncValue<List<Puzzle>>> {
  PuzzleController(this.store) : super(const AsyncValue.loading());

  final LocalStore store;

  Future<void> load() async {
    state = AsyncValue.data(await store.loadPuzzles());
  }

  Future<void> add(Puzzle puzzle) async {
    final List<Puzzle> list = [
      puzzle,
      ...(state.valueOrNull ?? <Puzzle>[]),
    ];
    await store.savePuzzles(list);
    state = AsyncValue.data(list);
  }

  Future<void> update(Puzzle puzzle) async {
    final List<Puzzle> list = [...(state.valueOrNull ?? <Puzzle>[])];
    final index = list.indexWhere((item) => item.id == puzzle.id);
    if (index == -1) return;
    list[index] = puzzle;
    await store.savePuzzles(list);
    state = AsyncValue.data(list);
  }

  Future<void> delete(String id) async {
    final List<Puzzle> list = [
      ...(state.valueOrNull ?? <Puzzle>[]),
    ]..removeWhere((item) => item.id == id);

    await store.savePuzzles(list);
    state = AsyncValue.data(list);
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(contentProvider).valueOrNull ?? [];
    final puzzles = ref.watch(puzzleProvider).valueOrNull ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('استودیو محتوا و جدول'), centerTitle: false),
      body: IndexedStack(index: tab, children: [
        _Dashboard(contents: contents, puzzles: puzzles,
          onAddContent: _editContent, onAddPuzzle: _addPuzzle),
        _ContentList(contents: contents, onEdit: _editContent,
          onDelete: (id) => ref.read(contentProvider.notifier).delete(id)),
        _PuzzleList(puzzles: puzzles, onAdd: _addPuzzle),
      ]),
      floatingActionButton: tab == 1
        ? FloatingActionButton.extended(onPressed: () => _editContent(), icon: const Icon(Icons.add), label: const Text('محتوای جدید'))
        : tab == 2
          ? FloatingActionButton.extended(onPressed: _addPuzzle, icon: const Icon(Icons.grid_on), label: const Text('جدول جدید'))
          : null,
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'محتوا'),
          NavigationDestination(icon: Icon(Icons.extension_outlined), selectedIcon: Icon(Icons.extension), label: 'جدول‌ها'),
        ]),
    );
  }

  Future<void> _editContent([ContentItem? existing]) async {
    final result = await Navigator.push<ContentItem>(context, MaterialPageRoute(
      builder: (_) => ContentEditorScreen(item: existing)));
    if (result != null && mounted) await ref.read(contentProvider.notifier).save(result);
  }
  Future<void> _addPuzzle() async {
    final contents = ref.read(contentProvider).valueOrNull ?? [];
    final result = await showDialog<Puzzle>(context: context,
      builder: (_) => _NewPuzzleDialog(contents: contents));
    if (result != null && mounted) await ref.read(puzzleProvider.notifier).add(result);
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.contents, required this.puzzles, required this.onAddContent, required this.onAddPuzzle});
  final List<ContentItem> contents; final List<Puzzle> puzzles;
  final VoidCallback onAddContent, onAddPuzzle;
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF176B67), Color(0xFF2D9186)]),
      borderRadius: BorderRadius.circular(22)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ایده‌هایت را ثبت کن، به بازی تبدیل کن', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), Text('محتوا، تمرین و جدول‌های تعاملی در یک فضای واحد.', style: TextStyle(color: Colors.white70)),
      ])),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _StatCard(label: 'محتواها', value: '${contents.length}', icon: Icons.article_outlined)),
      const SizedBox(width: 12), Expanded(child: _StatCard(label: 'جدول‌ها', value: '${puzzles.length}', icon: Icons.grid_on)),
    ]),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: onAddContent, icon: const Icon(Icons.add), label: const Text('ثبت محتوای جدید')),
    const SizedBox(height: 10), OutlinedButton.icon(onPressed: onAddPuzzle, icon: const Icon(Icons.extension), label: const Text('ساخت جدول جدید')),
    const SizedBox(height: 24), Text('آخرین محتواها', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8),
    if (contents.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('هنوز محتوایی ثبت نشده است.'))),
    ...contents.take(4).map((c) => Card(child: ListTile(leading: const Icon(Icons.description_outlined), title: Text(c.title.isEmpty ? 'بدون عنوان' : c.title), subtitle: Text(c.category)))),
  ]);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label, value; final IconData icon;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
    Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.headlineMedium), Text(label)]),
  ])));
}

class _ContentList extends StatelessWidget {
  const _ContentList({required this.contents, required this.onEdit, required this.onDelete});
  final List<ContentItem> contents; final ValueChanged<ContentItem> onEdit; final ValueChanged<String> onDelete;
  @override Widget build(BuildContext context) {
    if (contents.isEmpty) return const Center(child: Text('هنوز محتوایی ندارید. برای شروع + را بزنید.'));
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: contents.length, itemBuilder: (context, i) {
      final item = contents[i];
      return Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
        title: Text(item.title.isEmpty ? 'بدون عنوان' : item.title),
        subtitle: Text('${item.category} • ${item.mode == ContentMode.blocks ? 'بلوک‌محور' : 'متن غنی'}'),
        onTap: () => onEdit(item),
        trailing: PopupMenuButton<String>(onSelected: (v) {
          if (v == 'edit') onEdit(item);
          if (v == 'delete') onDelete(item.id);
        }, itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('ویرایش')),
          PopupMenuItem(value: 'delete', child: Text('حذف')),
        ]),
      ));
    });
  }
}

class _PuzzleList extends StatelessWidget {
  const _PuzzleList({required this.puzzles, required this.onAdd});
  final List<Puzzle> puzzles; final VoidCallback onAdd;
  @override Widget build(BuildContext context) {
    if (puzzles.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.grid_on, size: 56), const SizedBox(height: 12), const Text('هنوز جدولی نساخته‌اید.'),
      const SizedBox(height: 12), FilledButton(onPressed: onAdd, child: const Text('ساخت اولین جدول')),
    ]));
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: puzzles.length, itemBuilder: (_, i) {
      final p = puzzles[i];
      return Card(child: ListTile(leading: const Icon(Icons.grid_4x4), title: Text(p.title), subtitle: Text(p.type.label)));
    });
  }
}

class ContentEditorScreen extends StatefulWidget {
  const ContentEditorScreen({super.key, this.item});
  final ContentItem? item;
  @override State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}
class _ContentEditorScreenState extends State<ContentEditorScreen> {
  late final TextEditingController title, body, category, tags;
  late ContentMode mode;
  final List<ContentBlock> blocks = [];
  @override void initState() {
    super.initState();
    final item = widget.item;
    title = TextEditingController(text: item?.title ?? '');
    body = TextEditingController(text: item?.body ?? '');
    category = TextEditingController(text: item?.category ?? 'عمومی');
    tags = TextEditingController(text: item?.tags.join(', ') ?? '');
    mode = item?.mode ?? ContentMode.richText;
    blocks.addAll(item?.blocks ?? []);
  }
  @override void dispose() { title.dispose(); body.dispose(); category.dispose(); tags.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.item == null ? 'ثبت محتوا' : 'ویرایش محتوا'),
      actions: [TextButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('ذخیره'))]),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان محتوا')),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته‌بندی'))),
        const SizedBox(width: 10), Expanded(child: TextField(controller: tags, decoration: const InputDecoration(labelText: 'برچسب‌ها', hintText: 'آموزش، علوم'))),
      ]),
      const SizedBox(height: 18),
      SegmentedButton<ContentMode>(segments: const [
        ButtonSegment(value: ContentMode.richText, label: Text('متن غنی'), icon: Icon(Icons.text_fields)),
        ButtonSegment(value: ContentMode.blocks, label: Text('بلوک‌محور'), icon: Icon(Icons.view_agenda_outlined)),
      ], selected: {mode}, onSelectionChanged: (s) => setState(() => mode = s.first)),
      const SizedBox(height: 12),
      if (mode == ContentMode.richText) ...[
        const Text('ویرایشگر متن (نسخه پایه)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          ActionChip(label: const Text('تیتر'), onPressed: () => _insertPrefix('## ')),
          ActionChip(label: const Text('بولد **'), onPressed: () => _insertPrefix('**')),
          ActionChip(label: const Text('فهرست •'), onPressed: () => _insertPrefix('• ')),
        ]),
        const SizedBox(height: 8),
        TextField(controller: body, minLines: 10, maxLines: 20, decoration: const InputDecoration(
          alignLabelWithHint: true, labelText: 'متن محتوا', hintText: 'متن، لینک‌ها و نشانه‌گذاری را اینجا وارد کنید...')),
      ] else ...[
        Row(children: [const Expanded(child: Text('بلوک‌های محتوا', style: TextStyle(fontWeight: FontWeight.bold))), PopupMenuButton<String>(
          onSelected: _addBlock, itemBuilder: (_) => const [
            PopupMenuItem(value: 'text', child: Text('بلوک متن')),
            PopupMenuItem(value: 'image', child: Text('بلوک تصویر (نشانی)')),
            PopupMenuItem(value: 'link', child: Text('بلوک لینک')),
            PopupMenuItem(value: 'table', child: Text('بلوک جدول (توضیح متنی)')),
          ], child: const Chip(avatar: Icon(Icons.add), label: Text('افزودن بلوک')))]),
        const SizedBox(height: 8),
        if (blocks.isEmpty) const Text('از «افزودن بلوک» برای ساخت محتوای ترکیبی استفاده کنید.'),
        ...blocks.asMap().entries.map((entry) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('بلوک ${entry.key + 1}: ${_blockLabel(entry.value.type)}')), IconButton(onPressed: () => setState(() => blocks.removeAt(entry.key)), icon: const Icon(Icons.delete_outline))]),
            TextFormField(initialValue: entry.value.text, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'محتوا / URL'),
              onChanged: (v) => blocks[entry.key] = ContentBlock(id: entry.value.id, type: entry.value.type, text: v)),
          ])))),
      ],
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('ذخیره محتوا')),
    ]),
  );
  void _insertPrefix(String prefix) {
    final selection = body.selection;
    final start = selection.isValid ? selection.start : body.text.length;
    final end = selection.isValid ? selection.end : body.text.length;
    body.text = body.text.replaceRange(start, end, '$prefix${body.text.substring(start, end)}');
    body.selection = TextSelection.collapsed(offset: start + prefix.length + (end - start));
  }
  void _addBlock(String type) {
    setState(() => blocks.add(ContentBlock(id: DateTime.now().microsecondsSinceEpoch.toString(), type: type, text: '')));
  }
  String _blockLabel(String type) => switch(type) {'image' => 'تصویر', 'link' => 'لینک', 'table' => 'جدول', _ => 'متن'};
  void _save() {
    final now = DateTime.now();
    Navigator.pop(context, ContentItem(
      id: widget.item?.id ?? now.microsecondsSinceEpoch.toString(),
      title: title.text.trim(), body: body.text, category: category.text.trim().isEmpty ? 'عمومی' : category.text.trim(),
      tags: tags.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      mode: mode, blocks: List.unmodifiable(blocks), updatedAt: now,
    ));
  }
}

class _NewPuzzleDialog extends StatefulWidget {
  const _NewPuzzleDialog({required this.contents});
  final List<ContentItem> contents;
  @override State<_NewPuzzleDialog> createState() => _NewPuzzleDialogState();
}
class _NewPuzzleDialogState extends State<_NewPuzzleDialog> {
  final title = TextEditingController();
  PuzzleType type = PuzzleType.crossword;
  String? contentId;
  @override void dispose() { title.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Text('ساخت جدول جدید'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان جدول')),
      const SizedBox(height: 12),
      DropdownButtonFormField<PuzzleType>(value: type, decoration: const InputDecoration(labelText: 'نوع جدول'),
        items: PuzzleType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
        onChanged: (v) => setState(() => type = v ?? PuzzleType.crossword)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String?>(value: contentId, decoration: const InputDecoration(labelText: 'محتوای منبع (اختیاری)'),
        items: [const DropdownMenuItem<String?>(value: null, child: Text('بدون محتوای منبع')),
          ...widget.contents.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.title.isEmpty ? 'بدون عنوان' : c.title)))],
        onChanged: (v) => setState(() => contentId = v)),
      const SizedBox(height: 8),
      const Text('در این نسخه، مشخصات جدول ذخیره می‌شود. موتور حل و تولید خودکار جدول مرحله بعدی توسعه است.',
        style: TextStyle(fontSize: 12)),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
      FilledButton(onPressed: () {
        final now = DateTime.now();
        Navigator.pop(context, Puzzle(id: now.microsecondsSinceEpoch.toString(),
          title: title.text.trim().isEmpty ? type.label : title.text.trim(),
          type: type, contentId: contentId, createdAt: now));
      }, child: const Text('ساخت')),
    ],
  );
}
