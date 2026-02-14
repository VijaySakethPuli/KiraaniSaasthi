import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_agent/core/services/gemini_service.dart';
import 'package:shop_agent/core/services/firestore_service.dart';
import 'package:shop_agent/core/models/inventory_item.dart';
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

  final _geminiService = GeminiService();
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: (val) => debugPrint('onError: $val'),
      onStatus: (val) => debugPrint('onStatus: $val'),
    );
    _searchController.addListener(() {
      setState(() {});
    });
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

  void _showAddManualDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Item',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await _firestoreService.addInventoryItem({
                      'name': nameController.text,
                      'qty': qtyController.text,
                      'price': priceController.text,
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Add to Inventory'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(InventoryItem item) {
    final nameController = TextEditingController(text: item.name);
    final qtyController = TextEditingController(text: item.qty);
    final priceController = TextEditingController(text: item.price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Item',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    _firestoreService.deleteItem(item.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item deleted')),
                    );
                  },
                  icon: const Icon(PhosphorIconsRegular.trash, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await _firestoreService.updateInventoryItem(item.id, {
                    'name': nameController.text,
                    'qty': qtyController.text,
                    'price': priceController.text,
                  });
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    
    if (_lastWords.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing with Gemini...')),
      );

      final result = await _geminiService.parseOrder(_lastWords);
      
      if (result != null) {
        // Add to Firestore
        await _firestoreService.addInventoryItem(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Added: ${result['name']} (${result['qty']})")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to understand order.')),
          );
        }
      }
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
                  
                  // Wrap the rest of the UI in StreamBuilder to get real-time stats and list
                  Expanded(
                    child: StreamBuilder<List<InventoryItem>>(
                      stream: _firestoreService.getInventoryStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading inventory', style: TextStyle(color: Colors.red)));
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final allItems = snapshot.data!;
                        final filteredItems = allItems.where((item) {
                          final query = _searchController.text.toLowerCase();
                          return item.name.toLowerCase().contains(query);
                        }).toList();

                        // Calculate Stats
                        final totalItems = allItems.length;
                        final lowStockCount = allItems.where((item) {
                          // Simple heuristic: if quantity starts with a number < 10
                          final match = RegExp(r'^(\d+)').firstMatch(item.qty);
                          if (match != null) {
                            final val = int.tryParse(match.group(1) ?? '100');
                            return (val ?? 100) < 10;
                          }
                          return false;
                        }).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Updated Stats Cards
                            Row(
                              children: [
                                _buildStatCard('Total Items', totalItems.toString(), PhosphorIconsRegular.package, Colors.blue),
                                const SizedBox(width: 12),
                                _buildStatCard('Low Stock', lowStockCount.toString(), PhosphorIconsRegular.warning, Colors.orange),
                              ],
                            ).animate().fadeIn(delay: 500.ms),

                            const SizedBox(height: 24),

                            // Inventory Grid Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Inventory',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddManualDialog,
                                  icon: Icon(PhosphorIconsRegular.plus, size: 16),
                                  label: const Text('Add Manually'),
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms),

                            const SizedBox(height: 12),

                            // The Grid
                            Expanded(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIconsDuotone.package, size: 64, color: Colors.white24),
                                          const SizedBox(height: 16),
                                          Text(
                                            _searchController.text.isEmpty 
                                                ? 'No items yet.\nTry adding one via voice!'
                                                : 'No items match your search.',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white54, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    )
                                  : MasonryGridView.count(
                                      padding: const EdgeInsets.only(bottom: 100),
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        final random = Random(item.name.hashCode);
                                        final color = Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

                                        return GestureDetector(
                                          onTap: () => _showEditDialog(item),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E293B),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.2),
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      PhosphorIconsDuotone.package,
                                                      size: 48,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.qty,
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.6),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            item.price,
                                                            style: TextStyle(
                                                              color: Theme.of(context).primaryColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).animate().scale(delay: (50 * index).ms, duration: 300.ms, curve: Curves.easeOutBack);
                                      },
                                    ),
                            ),
                          ],
                        );
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
