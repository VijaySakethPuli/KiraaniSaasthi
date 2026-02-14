import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _lastWords = '';
  bool _speechEnabled = false;

  // Dummy Data for Inventory
  final List<Map<String, dynamic>> _inventory = [
    {'name': 'Basmati Rice', 'qty': '50 kg', 'price': '₹4,500', 'color': 0xFFFCD34D},
    {'name': 'Sunflower Oil', 'qty': '20 L', 'price': '₹2,800', 'color': 0xFFF87171},
    {'name': 'Sugar', 'qty': '100 kg', 'price': '₹3,200', 'color': 0xFF60A5FA},
    {'name': 'Atta (Flour)', 'qty': '75 kg', 'price': '₹2,100', 'color': 0xFFA78BFA},
    {'name': 'Toor Dal', 'qty': '30 kg', 'price': '₹3,600', 'color': 0xFF34D399},
    {'name': 'Masala Tea', 'qty': '10 kg', 'price': '₹1,500', 'color': 0xFFFB923C},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) => print('onStatus: $val'),
    );
    setState(() {});
  }

  void _startListening() async {
    // Request microphone permission explicitly for Android 
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required for voice commands')),
      );
      return;
    }

    if (!_speechEnabled) {
      await _speech.initialize();
    }

    await _speech.listen(onResult: (val) {
      setState(() {
        _lastWords = val.recognizedWords;
      });
    });

    setState(() {
      _isListening = true;
      _lastWords = ''; 
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    // TODO: Process the _lastWords with Gemini here
    if (_lastWords.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing: "$_lastWords"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 4.seconds),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, Vijay!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().moveY(begin: -10),
                          Text(
                            'Your Shop Dashboard',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white60,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white10,
                        backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ).animate().scale(delay: 300.ms),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(PhosphorIconsRegular.faders, size: 16, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).moveY(begin: 10),

                  const SizedBox(height: 24),

                  // Quick Stats
                  Row(
                    children: [
                      _buildStatCard('Total Items', '142', PhosphorIconsRegular.package, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard('Low Stock', '8', PhosphorIconsRegular.warning, Colors.orange),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Inventory Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inventory',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(PhosphorIconsRegular.plus, size: 16),
                        label: const Text('Add Manually'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 12),

                  Expanded(
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: _inventory.length,
                      itemBuilder: (context, index) {
                        final item = _inventory[index];
                        return _buildInventoryCard(item)
                            .animate()
                            .fadeIn(delay: (600 + (index * 100)).ms)
                            .moveY(begin: 20);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Voice Agent Overlay
          _buildVoiceAgentOverlay(),
        ],
      ),
      floatingActionButton: !_isListening 
          ? FloatingActionButton.extended(
              onPressed: _startListening,
              icon: Icon(PhosphorIconsFill.microphone),
              label: const Text('Voice Agent'),
            ).animate().scale(delay: 1.seconds)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(item['color']).withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(PhosphorIconsDuotone.basket, size: 40, color: Color(item['color'])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['qty'], style: const TextStyle(color: Colors.white70)),
                    Text(item['price'], style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAgentOverlay() {
    if (!_isListening) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: _stopListening,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 20,
                    )
                  ],
                ),
                child: Icon(PhosphorIconsFill.microphone, size: 40, color: Colors.white),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: Colors.white54)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1.seconds, curve: Curves.easeInOut),
              
              const SizedBox(height: 40),
              
              const Text(
                'Listening...',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().fadeIn().moveY(begin: 20),
              
              const SizedBox(height: 12),
              
              if (_lastWords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    '"$_lastWords"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic),
                  ).animate().fadeIn(),
                )
              else
                const Text(
                  'Try saying "Add 50kg rice worth 4500 rupees"',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 60),
              
              IconButton(
                onPressed: _stopListening,
                icon: const Icon(Icons.close, color: Colors.white60, size: 32),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
  
  // Helper for background blur if needed (dummy here)
  dynamic retrofitFilter() => null; 
}
