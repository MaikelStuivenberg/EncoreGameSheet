import 'package:flutter/material.dart';
import '../shared/widgets/game_input.dart';
import '../shared/widgets/game_button.dart';
import '../shared/supabase_client.dart';
import 'waiting_room_page.dart';

class JoinWithCodePage extends StatefulWidget {
  @override
  State<JoinWithCodePage> createState() => _JoinWithCodePageState();
}

class _JoinWithCodePageState extends State<JoinWithCodePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _joinGame() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    if (name.isEmpty || code.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Please enter your name and game code.';
      });
      return;
    }
    try {
      // Check if game exists
      final client = SupabaseClientManager.client;
      final game = await client
          .from('games')
          .select()
          .eq('code', code)
          .maybeSingle();
      if (game == null) {
        setState(() {
          _isLoading = false;
          _error = 'Game code not found.';
        });
        return;
      }
      // Add player if not already present
      final existing = await client
          .from('players')
          .select()
          .eq('game_code', code)
          .eq('name', name)
          .maybeSingle();
      if (existing != null) {
        setState(() {
          _isLoading = false;
          _error = 'This name is already taken in this game. Please choose another.';
        });
        return;
      }
      await client.from('players').insert({
        'game_code': code,
        'name': name,
      });
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingRoomPage(
              gameCode: code,
              hostName: game['host_name'] ?? '',
              playerName: name,
              selectedLevel: game['selected_level'] ?? 1,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to join game: \\${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join with Code'),
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
            const SizedBox(height: 16),
            GameInput(
              label: 'Game Code',
              controller: _codeController,
            ),
            const SizedBox(height: 24),
            GameButton.primary(
              _isLoading ? 'Loading...' : 'Join Game',
              _isLoading ? () {} : _joinGame,
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