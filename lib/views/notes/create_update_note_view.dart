import 'package:flutter/material.dart';
import 'package:mynotes/utils/generics/get_argument.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/ui_helpers.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final NotesService _notesService;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();
    _notesService = NotesService();

    // Listen to text changes and update the note
    _titleController.addListener(_updateNote);
    _textController.addListener(_updateNote);
  }

  /// Called whenever title or text changes
  void _updateNote() async {
    final note = _note;
    if (note == null) return;

    await _notesService.updateNote(
      note: note,
      title: _titleController.text,
      text: _textController.text,
    );
  }

  /// Get existing note from argument or create a new note
  Future<DatabaseNotes> _getOrCreateNote() async {
    final widgetNote = context.getArgument<DatabaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    if (_note != null) return _note!;

    final currentUser = AuthService.firebase().currentUser!;
    final owner = await _notesService.getUser(email: currentUser.email!);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  /// Deletes the note if both title and text are empty
  void _deleteNoteIfEmpty() {
    final note = _note;
    if (note != null &&
        _titleController.text.isEmpty &&
        _textController.text.isEmpty) {
      _notesService.deleteNote(id: note.id);
    }
  }

  /// Saves note if it has content
  Future<void> _saveNoteIfNotEmpty() async {
    final note = _note;
    if (note != null && _titleController.text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        title: _titleController.text,
        text: _textController.text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();

    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<DatabaseNotes>(
        future: _getOrCreateNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return NoteHelpers.buildLoadingShimmer(context);
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(context),
                  const SizedBox(height: 10),
                  _buildTextField(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// AppBar with custom note badge
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      title: _buildNoteBadge(),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.share), iconSize: 20),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert_outlined),
          iconSize: 25,
        ),
      ],
    );
  }

  /// Badge widget for AppBar
  Widget _buildNoteBadge() {
    return Container(
      height: 20,
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.note_add, size: 13, color: Colors.white),
            SizedBox(width: 5),
            Text(
              "Your Notes",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// Title TextField
  Widget _buildTitleField(BuildContext context) {
    return TextField(
      controller: _titleController,
      maxLines: 1,
      maxLength: 20,
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: Colors.transparent,
      ),
      autofocus: true,
      style: Theme.of(context).textTheme.displayLarge,
    );
  }

  /// Note TextField
  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: _textController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: Colors.transparent,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
