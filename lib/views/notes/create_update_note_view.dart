import 'package:flutter/material.dart';
import 'package:mynotes/utils/generics/get_argument.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;
  late final NotesService _notesService;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
    _titleController = TextEditingController();
    _notesService = NotesService();

    _textController.addListener(_onTextOrTitleChanged);
    _titleController.addListener(_onTextOrTitleChanged);
  }

  void _onTextOrTitleChanged() async {
    final note = _note;

    if (note == null) {
      return;
    }

    // This gets called whenever *either* field changes
    final title = _titleController.text;
    final text = _textController.text;

    await _notesService.updateNote(note: note, title: title, text: text);
  }

  Future<DatabaseNotes> getOrCreateNote() async {
    final widgetNote = context.getArgument<DatabaseNotes>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final owner = await _notesService.getUser(email: currentUser.email!);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty &&
        _titleController.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text, title: title);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();

    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: getOrCreateNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title TextField
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 10),
                    // Note TextField
                    TextField(
                      autofocus: true,
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Start typing your note here...',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
