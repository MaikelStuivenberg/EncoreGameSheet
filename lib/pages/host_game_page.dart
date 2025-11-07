import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/supabase_client.dart';
import 'dart:math';
import '../shared/widgets/game_button.dart';
import '../shared/widgets/game_input.dart';
import '../constants/settings.dart';
import 'waiting_room_page.dart';

class HostGamePage extends StatefulWidget {
  @override
  State<HostGamePage> createState() => _HostGamePageState();
}

class _HostGamePageState extends State<HostGamePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  int selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadLastPlayerName();
  }

  Future<void> _loadLastPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayerName = prefs.getString(Settings.lastPlayerName);
    if (lastPlayerName != null && lastPlayerName.isNotEmpty) {
      _nameController.text = lastPlayerName;
    }
  }

  String _generateCode([int length = 6]) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  Future<void> _createGame() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Please enter your name.';
      });
      return;
    }
    String code = _generateCode();
    try {
      // Try to insert, retry if code collision
      bool success = false;
      int attempts = 0;
      while (!success && attempts < 5) {
        final response = await SupabaseClientManager.client
            .from('games')
            .insert({
              'code': code,
              'host_name': name,
              'selected_level': selectedLevel,
            })
            .select()
            .single();
        if (response['code'] == code) {
          success = true;
        } else {
          code = _generateCode();
        }
        attempts++;
      }
      if (!success) throw Exception('Could not generate a unique code.');

      // Save the player name for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Settings.lastPlayerName, name);

      setState(() {
        _isLoading = false;
      });
      // Navigate to waiting room
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingRoomPage(
              gameCode: code,
              hostName: name,
              playerName: name,
              isHost: true,
              selectedLevel: selectedLevel,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error =
            'It currently is not possible to start a (online) game due to technical issues. Please try again later.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameInput(
              label: 'Your Name',
              controller: _nameController,
            ),
            const SizedBox(height: 24),
            GameButton.primary(
              _isLoading ? 'Loading...' : 'Generate Game Code',
              _isLoading ? () {} : _createGame,
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
