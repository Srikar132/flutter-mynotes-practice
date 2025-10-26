import 'package:flutter/material.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/notes/search_notes_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 2) {
      return const CreateUpdateNoteView();
    }

    return IndexedStack(
      index: _selectedIndex,
      children: const [
        NotesView(),      // Index 0
        SearchNotesView(), // Index 1
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBarTheme(
      data: const NavigationBarThemeData(
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.transparent,
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 30),
            selectedIcon: Icon(Icons.home, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, size: 30),
            selectedIcon: Icon(Icons.search, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_add_outlined, size: 28),
            selectedIcon: Icon(Icons.note_add, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}