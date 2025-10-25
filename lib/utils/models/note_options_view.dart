import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:share_plus/share_plus.dart'; // Add to pubspec.yaml if sharing feature needed

class NoteOptionsModal extends StatelessWidget {
  final DatabaseNotes note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteOptionsModal({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  static void show(
    BuildContext context, {
    required DatabaseNotes note,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NoteOptionsModal(
        note: note,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Note preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                const SizedBox(height: 4),
                Text(
                  note.text == '' ? 'No content' : note.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 10,
              color: Colors.grey,
            ),
          ),

          // Options
          _buildOption(
            context,
            icon: Icons.edit_outlined,
            label: 'Edit Note',
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          _buildOption(
            context,
            icon: Icons.share_outlined,
            label: 'Share Note',
            onTap: () {
              Navigator.pop(context);
              _shareNote(context);
            },
          ),
          _buildOption(
            context,
            icon: Icons.copy_outlined,
            label: 'Copy to Clipboard',
            onTap: () {
              Navigator.pop(context);
              _copyToClipboard(context);
            },
          ),
          _buildOption(
            context,
            icon: Icons.push_pin_outlined,
            label: 'Pin Note',
            onTap: () {
              Navigator.pop(context);
              _pinNote(context);
            },
          ),
          _buildOption(
            context,
            icon: Icons.archive_outlined,
            label: 'Archive Note',
            onTap: () {
              Navigator.pop(context);
              _archiveNote(context);
            },
          ),
          _buildOption(
            context,
            icon: Icons.delete_outline,
            label: 'Delete Note',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive
                  ? Colors.red
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDestructive
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareNote(BuildContext context)async  {
    final content = '${note.title == '' ? 'Untitled' : note.title}\n\n${note.text == '' ? 'No content' : note.text}';
    await Share.share(content);
  }

  void _copyToClipboard(BuildContext context) {
    // Implement copy to clipboard
    // 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note copied to clipboard')),
    );
  }

  void _pinNote(BuildContext context) {
    // Implement pin functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note pinned')),
    );
  }

  void _archiveNote(BuildContext context) {
    // Implement archive functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note archived')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}