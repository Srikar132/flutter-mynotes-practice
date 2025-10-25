import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/models/note_options_view.dart';
// import 'package:mynotes/utils/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final NoteCallback onTap;
  final NoteCallback onDelete;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Theme.of(context).dividerColor.withAlpha(10),
          thickness: 0.8,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _buildNoteCard(context, note, index);
        },
      ),
    );
  }



  Widget _buildNoteCard(BuildContext context, DatabaseNotes note, int index) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: index == 0 ? const Radius.circular(10) : Radius.zero,
          topRight: index == 0 ? const Radius.circular(10) : Radius.zero,
          bottomLeft: index == notes.length - 1
              ? const Radius.circular(10)
              : Radius.zero,
          bottomRight: index == notes.length - 1
              ? const Radius.circular(10)
              : Radius.zero,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title == '' ? 'Untitled' : note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              // Three dots menu button
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  NoteOptionsModal.show(
                    context,
                    note: note,
                    onEdit: () => onTap(note),
                    onDelete: () => onDelete(note),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
