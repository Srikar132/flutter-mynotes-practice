import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/log_out_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AuthService _authService;
  late final NotesService _notesService;

  // Consistent padding values
  static const double _horizontalPadding = 15.0;
  static const double _verticalPadding = 15.0;
  static const double _itemSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _authService = AuthService.firebase();
  }

  String get userEmail => _authService.currentUser?.email ?? '';

  String get userInitial =>
      _authService.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U';

  String get userName => userEmail.split("@").first;

  Future<void> _handleLogOut(BuildContext context) async {
    try {
      await _authService.logOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'logout':
        final shouldLogOut = await showLogOutDialog(context);
        if (shouldLogOut && mounted) {
          await _handleLogOut(context);
        }
        break;
      case 'settings':
        // Navigate to settings page
        // Navigator.of(context).pushNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          5,
          _horizontalPadding,
          _verticalPadding,
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildNotesContent(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      toolbarHeight: 60,
      leading: _buildUserAvatar(context),
      title: _buildAppBarTitle(context),
      actions: [_buildPopupMenu()],
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        height: 30,
        width: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDarkMode
              ? Theme.of(context).colorScheme.primary.withAlpha(80)
              : Colors.white,
          border: !isDarkMode
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.2,
                )
              : null,
        ),
        padding: const EdgeInsets.all(0.5),
        child: Text(
          userInitial,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Text(
      "$userName's Notes",
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'logout',
          icon: Icons.logout_sharp,
          label: 'Logout',
        ),
        _buildPopupMenuItem(
          value: 'settings',
          icon: Icons.settings,
          label: 'Settings',
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem(
      value: value,
      child: SizedBox(
        width: 180,
        child: Row(
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: _itemSpacing),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('All Notes'),

        // make IconsButton's padding to zero
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
          icon: const Icon(Icons.add , size: 20,),
        ),
      ],
    );
  }

  Widget _buildNotesContent() {
    return FutureBuilder(
      future: _notesService.getOrCreateUser(email: userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildNotesStream();
        }
        return _buildLoadingShimmer();
      },
    );
  }

  Widget _buildNotesStream() {
    return StreamBuilder(
      stream: _notesService.allNotes,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            if (snapshot.hasData) {
              final allNotes = snapshot.data as List<DatabaseNotes>;
              
              if (allNotes.isEmpty) {
                return _buildPlaceholder(
                  'No Notes are available, create your first note',
                );
              }
              
              return NotesListView(
                notes: allNotes,
                onTap: (note) {
                  Navigator.of(context).pushNamed(
                    createOrUpdateNoteRoute,
                    arguments: note,
                  );
                },
                onDelete: (note) async {
                  await _notesService.deleteNote(id: note.id);
                },
              );
            }
            
            return _buildPlaceholder(
              'Trying to get notes from the cache of your device...',
            );

          default:
            return _buildPlaceholder(
              'Trying to get notes from the cache of your device...',
            );
        }
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
      highlightColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
      child: Container(
        width: double.infinity,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 12,
      ),
      child: Text(title),
    );
  }
}