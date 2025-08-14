import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyLottoApp());

class MyLottoApp extends StatefulWidget {
  @override
  _MyLottoAppState createState() => _MyLottoAppState();
}

class _MyLottoAppState extends State<MyLottoApp> {
  bool isDarkMode = false;
  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLottoApp',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class LottoConfig {
  final String name;
  final int maxNumber;
  final int picks;
  final String prefix;
  final IconData icon;
  LottoConfig({
    required this.name,
    required this.maxNumber,
    required this.picks,
    required this.prefix,
    required this.icon,
  });
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  HomeScreen({required this.onThemeToggle, required this.isDarkMode});

  final List<LottoConfig> configs = [
    LottoConfig(name: 'Ötöslottó',  maxNumber: 90, picks: 5, prefix: 'L5', icon: Icons.filter_5),
    LottoConfig(name: 'Hatoslottó',  maxNumber: 45, picks: 6, prefix: 'L6', icon: Icons.filter_6),
    LottoConfig(name: 'Skandináv',   maxNumber: 35, picks: 7, prefix: 'LS', icon: Icons.filter_7),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyLottoApp'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: configs.map((cfg) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LottoComposeScreen(config: cfg)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cfg.icon, size: 56, color: scheme.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text(
                      cfg.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class LottoComposeScreen extends StatefulWidget {
  final LottoConfig config;
  const LottoComposeScreen({required this.config});

  @override
  State<LottoComposeScreen> createState() => _LottoComposeScreenState();
}

class _LottoComposeScreenState extends State<LottoComposeScreen> {
  List<int> currentSelection = [];
  final List<List<int>> tickets = [];

  // Egy szelvény blokk-stringje (rendezve)
  String _ticketBlock(List<int> numbers) {
    final sorted = List<int>.from(numbers)..sort();
    return sorted.map((n) => '#$n').join();
  }

  void pickRandom() {
    final r = Random();
    final set = <int>{};
    while (set.length < widget.config.picks) {
      set.add(r.nextInt(widget.config.maxNumber) + 1);
    }
    setState(() => currentSelection = (set.toList()..sort()));
  }

  void toggleNumber(int n) {
    setState(() {
      if (currentSelection.contains(n)) {
        currentSelection.remove(n);
      } else if (currentSelection.length < widget.config.picks) {
        currentSelection.add(n);
      }
      currentSelection.sort();
    });
  }

  void clearCurrent() {
    setState(() => currentSelection.clear());
  }

  void addCurrentAsTicket() {
    if (currentSelection.length != widget.config.picks) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pontosan ${widget.config.picks} számot jelölj ki.')),
      );
      return;
    }
    if (tickets.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Egyszerre legfeljebb 5 szelvény lehet.')),
      );
      return;
    }

    final newBlock = _ticketBlock(currentSelection);
    final alreadyExists = tickets.any((t) => _ticketBlock(t) == newBlock);
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ez a szelvény már szerepel a listában.')),
      );
      return;
    }

    setState(() {
      tickets.add(List<int>.from(currentSelection)..sort());
      currentSelection.clear();
    });
  }

  void editTicket(int index) {
    setState(() {
      currentSelection = List<int>.from(tickets[index])..sort();
      tickets.removeAt(index);
    });
  }

  void deleteTicket(int index) {
    setState(() => tickets.removeAt(index));
  }

  /// SMS üzenet:
  /// - deduplikál,
  /// - legfeljebb 5 blokk,
  /// - az aktuális csak akkor kerül be, ha teljes és van hely.
  String buildMessage() {
    final seen = <String>{};
    final parts = <String>[];

    // 1) Felvett szelvények, max. 5-ig
    for (final t in tickets) {
      final block = _ticketBlock(t);
      if (seen.add(block)) {
        parts.add(block);
        if (parts.length == 5) break;
      }
    }

    // 2) Aktuális kijelölés, ha teljes + még van hely + nem duplikátum
    final readyCurrent = currentSelection.length == widget.config.picks;
    if (readyCurrent && parts.length < 5) {
      final currentBlock = _ticketBlock(currentSelection);
      if (seen.add(currentBlock)) {
        parts.add(currentBlock);
      }
    }

    return '${widget.config.prefix}${parts.isEmpty ? '' : parts.join('##')}';
  }

  Future<void> openSmsApp() async {
    final readyCurrent = currentSelection.length == widget.config.picks;
    final canSend = tickets.isNotEmpty || readyCurrent;

    if (!canSend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adj meg egy teljes szelvényt, vagy vedd fel a listába.')),
      );
      return;
    }

    final msg = buildMessage();
    final uri = Uri.parse('sms:1756?body=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nem sikerült megnyitni az SMS alkalmazást')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final readyCurrent = currentSelection.length == widget.config.picks;
    final canSend = tickets.isNotEmpty || readyCurrent;

    return Scaffold(
      appBar: AppBar(title: Text(widget.config.name)),
      body: Column(
        children: [
          // Felső sáv
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: pickRandom,
                  child: Text('Véletlen (${widget.config.picks})'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kijelölt: ${currentSelection.length}/${widget.config.picks}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: currentSelection.isNotEmpty ? clearCurrent : null,
                  child: const Text('Törlés'),
                ),
              ],
            ),
          ),

          // Számválasztó GRID – egységes csempeméret minden játéknál
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Fix 10 oszlop → azonos szélességű gombok
                const cols = 10;
                // Ötöslottó 90 száma 10 oszlopban = 9 sor → ehhez igazítjuk a magasságot
                const referenceRows = 9;

                const padding = 8.0;
                const crossSpacing = 4.0;
                const mainSpacing = 4.0;

                final width = constraints.maxWidth - padding * 2;
                final height = constraints.maxHeight - padding * 2;

                final tileW = (width - (cols - 1) * crossSpacing) / cols;
                final tileHForRef = (height - (referenceRows - 1) * mainSpacing) / referenceRows;

                final aspect = tileW / tileHForRef;

                return GridView.builder(
                  padding: const EdgeInsets.all(padding),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: crossSpacing,
                    mainAxisSpacing: mainSpacing,
                    childAspectRatio: aspect,
                  ),
                  itemCount: widget.config.maxNumber,
                  itemBuilder: (context, i) {
                    final n = i + 1;
                    final sel = currentSelection.contains(n);
                    return GestureDetector(
                      onTap: () => toggleNumber(n),
                      child: Container(
                        decoration: BoxDecoration(
                          color: sel ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontSize: 12,
                              color: sel ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Új szelvény gomb + aktuális kijelölés
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Aktuális: ${currentSelection.join(', ')}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: readyCurrent ? addCurrentAsTicket : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Új szelvény'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Szelvénylista — mindig kifér 5 db görgetés nélkül
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (tickets.isEmpty) return const SizedBox.shrink();

                // Max 5 szelvényünk lehet → osszuk el egyenletesen a rendelkezésre álló térben
                final count = tickets.length; // 1..5
                const sepHeight = 1.0; // Divider magassága
                final totalSep = (count - 1) * sepHeight;
                final itemExtent = (constraints.maxHeight - totalSep) / count;

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: count,
                  separatorBuilder: (_, __) => const Divider(height: sepHeight),
                  itemBuilder: (context, i) {
                    final nums = tickets[i];
                    return SizedBox(
                      height: itemExtent,
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text(nums.join(', ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Szerkesztés',
                              icon: const Icon(Icons.edit),
                              onPressed: () => editTicket(i),
                            ),
                            IconButton(
                              tooltip: 'Törlés',
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTicket(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // SMS gomb – aktív akkor is, ha csak a currentSelection teljes
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: canSend ? openSmsApp : null,
              icon: const Icon(Icons.sms),
              label: const Text('SMS írása a 1756-ra'),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) return null;
                  return Colors.green;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) return null;
                  return Colors.white;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
