import 'package:flutter/material.dart';
import '../shared/widgets/game_button.dart';
import '../shared/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'game_page.dart';

class WaitingRoomPage extends StatefulWidget {
  final String gameCode;
  final String hostName;
  final String playerName;
  final bool? isHost;
  final int selectedLevel;

  const WaitingRoomPage({
    super.key,
    required this.gameCode,
    required this.hostName,
    required this.playerName,
    this.isHost,
    required this.selectedLevel,
  });

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  List<Map<String, dynamic>> players = [];
  RealtimeChannel? _channel;
  bool _isLoading = true;
  bool isHost = false;
  int selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.selectedLevel;
    _initRoom();
    _subscribeToGame();
  }

  Future<void> _initRoom() async {
    final client = SupabaseClientManager.client;
    final existing = await client
        .from('players')
        .select()
        .eq('game_code', widget.gameCode)
        .eq('name', widget.playerName)
        .maybeSingle();
    if (existing == null) {
      await client.from('players').insert({
        'game_code': widget.gameCode,
        'name': widget.playerName,
        'is_host': widget.isHost ?? false,
      });
    }
    await _fetchPlayers();
    _subscribeToPlayers();
  }

  Future<void> _fetchPlayers() async {
    final client = SupabaseClientManager.client;
    final data = await client
        .from('players')
        .select('name, is_host')
        .eq('game_code', widget.gameCode)
        .order('joined_at');
    setState(() {
      players = List<Map<String, dynamic>>.from(data);
      final me = players.firstWhere(
        (p) => p['name'] == widget.playerName,
        orElse: () => <String, dynamic>{},
      );
      isHost = (me.isNotEmpty && me['is_host'] == true);
      _isLoading = false;
    });
  }

  void _subscribeToPlayers() {
    final client = SupabaseClientManager.client;
    _channel = client.channel('public:players')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'players',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'game_code',
          value: widget.gameCode,
        ),
        callback: (payload) {
          _fetchPlayers();
        },
      )
      ..subscribe();
  }

  void _subscribeToGame() {
    final client = SupabaseClientManager.client;
    client
        .channel('public:games')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'games',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'code',
            value: widget.gameCode,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow['selected_level'] != null) {
              setState(() {
                selectedLevel = newRow['selected_level'] as int;
              });
            }
            if (newRow['game_started'] == true) {
              // Navigate to GamePage for all players
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      level: newRow['selected_level'] as int,
                      singlePlayer: false,
                      gameCode: widget.gameCode,
                      playerName: widget.playerName,
                    ),
                  ),
                );
              }
            }
          },
        )
        .subscribe();
  }

  void _changeLevel(int newLevel) async {
    setState(() {
      selectedLevel = newLevel;
    });
    await SupabaseClientManager.client
        .from('games')
        .update({'selected_level': newLevel}).eq('code', widget.gameCode);
  }

  void _startGame() async {
    // Fetch all players for this game
    final client = SupabaseClientManager.client;
    final data = await client
        .from('players')
        .select('name')
        .eq('game_code', widget.gameCode);
    final playerNames = List<String>.from(data.map((e) => e['name']));
    playerNames.shuffle();
    final startPlayer = playerNames.first;
    await client
        .from('games')
        .update({'game_started': true, 'current_turn': startPlayer}).eq(
            'code', widget.gameCode);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Widget _buildGameCardDisplay() {
    final images = [
      'assets/images/lvl1.jpg',
      'assets/images/lvl2.jpg',
      'assets/images/lvl3.jpg',
      'assets/images/lvl4.jpg',
      'assets/images/lvl5.jpg',
      'assets/images/lvl6.jpg',
      'assets/images/lvl7.jpg',
    ];
    if (isHost) {
      return SizedBox(
        height: 180,
        child: PageView.builder(
          controller: PageController(
              viewportFraction: 0.8, initialPage: selectedLevel - 1),
          itemCount: images.length,
          onPageChanged: (index) => _changeLevel(index + 1),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _changeLevel(index + 1),
              child: Hero(
                tag: images[index],
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 30, 30, 30),
                        image: DecorationImage(
                          image: AssetImage(images[index]),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20,
                      child: Text(
                        ' Level ${index + 1} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ),
                    if (selectedLevel == index + 1)
                      const Positioned(
                        top: 10,
                        right: 20,
                        child: Icon(Icons.check_circle,
                            color: Colors.green, size: 32),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      final idx = selectedLevel - 1;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 180,
          child: Hero(
            tag: images[idx],
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 30, 30, 30),
                    image: DecorationImage(
                      image: AssetImage(images[idx]),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: Text(
                    ' Level ${idx + 1} ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
                const Positioned(
                  top: 10,
                  right: 20,
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Game Code:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SelectableText(
              widget.gameCode,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildGameCardDisplay(),
            const SizedBox(height: 24),
            const Text(
              'Players in Room:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              ...players.map((p) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (p['is_host'] == true)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                '(Host)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 40),
            if (isHost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GameButton.primary(
                  'Start Game',
                  _startGame,
                ),
              ),
            if (!isHost)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Text(
                    'Waiting for the host to start the game...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
