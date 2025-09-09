import 'package:flutter/material.dart';
import 'package:mynotes/services/auth_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<void> _handleLogOut(BuildContext context) async {
    try {
      _authService.logOut();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
       
        leadingWidth: 60, // increase leading width to give more space
        titleSpacing: 0, // reduce space between leading and title

        toolbarHeight: 60, // increase toolbar height

        leading: Container(
          margin: const EdgeInsets.all(8),
          height: 30,
          width: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.all(0.5),
          child: Text(
            _authService.currentUser?.email?.substring(0, 1).toUpperCase() ??
                'U', // U for user if null
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        title: Container(
          alignment: Alignment.centerLeft, // 👈 forces left alignment
          child: Text(
            _authService.currentUser?.email ?? 'User',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        actions: [
          // make this a drop down and show log out there and also many options like profile settings etc
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),

            // make the menu items look better with icons and padding
            // offset: const Offset(-20, 50), // move left (-x) and down (+y)
            position: PopupMenuPosition.under, // makes sure it opens under button

            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    // ignore: use_build_context_synchronously
                    await _handleLogOut(context);
                  }
                  break;
                case 'settings':
                  // Navigate to settings page
                  // Navigator.of(context).pushNamed('/settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: SizedBox(
                  width: 180, // 👈 control the width here
                  child: Row(
                    children: const [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: SizedBox(
                  width: 180, // 👈 same width for consistency
                  child: Row(
                    children: const [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(children: []),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // return false
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // return true
            },
            child: const Text('Log Out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
