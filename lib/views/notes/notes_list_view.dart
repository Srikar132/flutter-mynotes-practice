import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/models/note_options_view.dart';

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
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _buildNoteCard(context, note);
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, DatabaseNotes note) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: InkWell(
          borderRadius: BorderRadius.zero,
          onTap: () => onTap(note),
          splashColor: theme.colorScheme.primary.withAlpha(30),
          highlightColor: theme.colorScheme.primary.withAlpha(15),
          child: Row(
            children: [
              _buildIconButton(
                context,
                icon: Icons.arrow_forward_ios,
                onPressed: () {},
                iconSize: 14
              ),

              // Note title
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              // Right-side icons
              Row(
                spacing: 0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    context,
                    icon: Icons.more_horiz_outlined,
                    onPressed: () {
                      NoteOptionsModal.show(
                        context,
                        note: note,
                        onEdit: () => onTap(note),
                        onDelete: () => onDelete(note),
                      );
                    },
                    iconSize: 25,
                  ),
                  _buildIconButton(
                    context,
                    icon: Icons.add,
                    onPressed: () {
                      // navigation to edit note
                      onTap(note);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    double iconSize = 20,
  }) {
    return IconButton(
      icon: Icon(icon, size: iconSize),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 18,
      color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
      onPressed: onPressed,
    );
  }
}
