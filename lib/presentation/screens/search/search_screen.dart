import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/document.dart';
import '../../../domain/repositories/document_repository.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Document> _results = [];
  bool _isSearching = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    final repo = ref.read(documentRepositoryProvider);
    final result = await repo.searchDocuments(
      query: query,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    result.fold(
      (_) => setState(() { _results = []; _isSearching = false; }),
      (docs) => setState(() { _results = docs; _isSearching = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            textDirection: TextDirection.rtl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'بحث في المستندات...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
            ),
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            onChanged: (v) => _search(v),
          ),
          actions: [
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() => _results = []);
                },
              ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
          ],
        ),
        body: _isSearching
            ? const Center(child: CircularProgressIndicator())
            : _controller.text.isEmpty
                ? _SearchHints()
                : _results.isEmpty
                    ? _NoResults(query: _controller.text)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              'نتائج البحث (${_results.length})',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (ctx, i) => DocumentCard(
                                document: _results[i],
                                onTap: () => context.push('/documents/${_results[i].id}'),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تصفية النتائج', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_fromDate == null ? 'من تاريخ' : 'من: ${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _fromDate = d);
                        Navigator.pop(ctx);
                        _search(_controller.text);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_toDate == null ? 'إلى تاريخ' : 'إلى: ${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _toDate = d);
                        Navigator.pop(ctx);
                        _search(_controller.text);
                      },
                    ),
                  ),
                ],
              ),
              if (_fromDate != null || _toDate != null)
                TextButton(
                  onPressed: () {
                    setState(() { _fromDate = null; _toDate = null; });
                    Navigator.pop(ctx);
                    _search(_controller.text);
                  },
                  child: const Text('إعادة تعيين', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('ابحث عن مستنداتك', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('يمكنك البحث بالعنوان أو المحتوى', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد نتائج لـ "$query"', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
