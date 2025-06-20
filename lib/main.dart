import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Ferrum());
}

class Ferrum extends StatefulWidget {
  const Ferrum({super.key});

  @override
  State<Ferrum> createState() => _FerrumState();
}

class _FerrumState extends State<Ferrum> {
  ThemeMode _themeMode = ThemeMode.dark;
  MaterialColor _primarySwatch = Colors.blue;

  void updateTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void updatePrimarySwatch(MaterialColor color) {
    setState(() {
      _primarySwatch = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferrum',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _primarySwatch,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _primarySwatch,
          brightness: Brightness.dark,
        ).copyWith(
          background: Colors.black,
          surface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: MyHomePage(
        updateTheme: updateTheme,
        updatePrimarySwatch: updatePrimarySwatch,
        currentThemeMode: _themeMode,
        currentPrimarySwatch: _primarySwatch,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(ThemeMode) updateTheme;
  final Function(MaterialColor) updatePrimarySwatch;
  final ThemeMode currentThemeMode;
  final MaterialColor currentPrimarySwatch;

  const MyHomePage({
    super.key,
    required this.updateTheme,
    required this.updatePrimarySwatch,
    required this.currentThemeMode,
    required this.currentPrimarySwatch,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<dynamic>> _wordDefinitions = {};
  bool _isLoading = false;
  // 存储收藏的单词及其释义
  final Map<String, List<Map<String, dynamic>>> _favorites = {};

  // 显示主题设置对话框
  void _showThemeSettings() {
    final List<MaterialColor> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.amber,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('主题设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('深色模式'),
                  Switch(
                    value: widget.currentThemeMode == ThemeMode.dark,
                    onChanged: (value) {
                      widget.updateTheme(value ? ThemeMode.dark : ThemeMode.light);
                      setState(() {}); // 刷新对话框状态
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('主题色：'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colorOptions.map((color) {
                      return InkWell(
                        onTap: () {
                          widget.updatePrimarySwatch(color);
                          setState(() {}); // 刷新对话框状态
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: widget.currentPrimarySwatch == color
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchWord(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _wordDefinitions = {};
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _wordDefinitions = {word: data[0]['meanings']};
        });
      } else {
        throw Exception('Failed to load word definition');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('查询失败，请稍后重试')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 添加或删除收藏
  void _toggleFavorite(String word, String partOfSpeech, String definition) {
    setState(() {
      if (!_favorites.containsKey(word)) {
        _favorites[word] = [];
      }

      final existingIndex = _favorites[word]!.indexWhere((f) =>
          f['partOfSpeech'] == partOfSpeech && f['definition'] == definition);

      if (existingIndex >= 0) {
        _favorites[word]!.removeAt(existingIndex);
        if (_favorites[word]!.isEmpty) {
          _favorites.remove(word);
        }
      } else {
        _favorites[word]!.add({
          'partOfSpeech': partOfSpeech,
          'definition': definition,
        });
      }
    });
  }

  // 检查是否已收藏
  bool _isFavorite(String word, String partOfSpeech, String definition) {
    if (!_favorites.containsKey(word)) return false;
    return _favorites[word]!.any((f) =>
        f['partOfSpeech'] == partOfSpeech && f['definition'] == definition);
  }

  // 显示收藏详情对话框
  void _showFavoriteDetails(String word, List<Map<String, dynamic>> definitions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: definitions.map((def) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        def['partOfSpeech'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(def['definition']),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.text = word;
              _searchWord(word);
            },
            child: const Text('查看完整释义'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search word...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _wordDefinitions = {};
                });
              },
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black
          ),
          onSubmitted: _searchWord,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showThemeSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final word = _favorites.keys.elementAt(index);
                    final definitions = _favorites[word]!;
                    return Card(
                      child: ListTile(
                        title: Text(word),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${definitions.first['definition']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (definitions.length > 1)
                              Text(
                                '还有 ${definitions.length - 1} 条释义...',
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _showFavoriteDetails(word, definitions),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _wordDefinitions.length,
                  itemBuilder: (context, index) {
                    final word = _wordDefinitions.keys.elementAt(index);
                    final meanings = _wordDefinitions[word]!;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...meanings.map<Widget>((meaning) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      meaning['partOfSpeech'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...meaning['definitions'].map<Widget>((def) {
                                    final bool isFavorite = _isFavorite(
                                      word,
                                      meaning['partOfSpeech'],
                                      def['definition'],
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 16)),
                                          Expanded(
                                            child: Text(
                                              def['definition'],
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? Theme.of(context).colorScheme.primary : null,
                                            ),
                                            onPressed: () => _toggleFavorite(
                                              word,
                                              meaning['partOfSpeech'],
                                              def['definition'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
