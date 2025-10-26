import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class SearchNotesView extends StatefulWidget {
  const SearchNotesView({super.key});

  @override
  State<SearchNotesView> createState() => _SearchNotesViewState();
}

class _SearchNotesViewState extends State<SearchNotesView> {
  late final TextEditingController _searchController;
  late final NotesService _notesService;
  late final AuthService _authService;

  List<DatabaseNotes> _searchResults = []; // Initialize with empty list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _notesService = NotesService();
    _authService = AuthService.firebase();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many calls
    _searchNotes();
  }

  Future<void> _searchNotes() async {
    final query = _searchController.text.trim();

    // Reset results if query is empty
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _authService.currentUser?.email;

      // Check if userId is null
      if (email == null) {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
          });
        }
        return;
      }

      final notes = await _notesService.searchNotes(email: email, query: query);

      if (mounted) {
        setState(() {
          _searchResults = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching notes: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _searchResults.isNotEmpty
          ? AppBar(
              // title: const Text('Search Results'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            // Search Input
            _buildSearchInputField(context),
            const SizedBox(height: 20),

            // Search Results
            Expanded(child: _buildSearchResults(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    // Show nothing if search is empty
    if (_searchController.text.trim().isEmpty) {
      return Container();
    }

    // Show loading indicator
    if (_isLoading) {
      return SizedBox();
    }

    // Show no results message
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).hintColor.withAlpha(70),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor.withAlpha(70),
              ),
            ),
          ],
        ),
      );
    }

    // Show search results
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title of "search result with count"
          Text(
            'Search Results (${_searchResults.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              // alignment: TextAlign.left,
            ),
          ),

          NotesListView(
            notes: _searchResults,
            onTap: (note) {
              Navigator.of(
                context,
              ).pushNamed(createOrUpdateNoteRoute, arguments: note);
            },
            onDelete: (note) async {
              await _notesService.deleteNote(id: note.id);
              await _searchNotes(); // Refresh search results after deletion
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputField(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        hintStyle: TextStyle(
          // ignore: deprecated_member_use
          color: Theme.of(context).hintColor.withOpacity(0.5),
        ),
        prefixIcon: _isLoading
            ? _buildCircularIndicator()
            : const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCircularIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondaryFixed,
          ),
        ),
      ),
    );
  }
}
