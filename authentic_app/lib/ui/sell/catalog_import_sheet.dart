import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/common.dart';

/// Search the open-source DummyJSON product catalog and pick a template.
class CatalogImportSheet extends ConsumerStatefulWidget {
  const CatalogImportSheet({super.key});

  @override
  ConsumerState<CatalogImportSheet> createState() => _CatalogImportSheetState();
}

class _CatalogImportSheetState extends ConsumerState<CatalogImportSheet> {
  String _query = 'phone';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(catalogSearchProvider(_query));
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search products, e.g. "watch", "laptop"',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorText(e),
                data: (items) => items.isEmpty
                    ? const EmptyState(icon: Icons.search_off, text: 'No products found.')
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final p = items[i];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: ListingImage(url: p.thumbnail, size: 48),
                            ),
                            title: Text(p.title),
                            subtitle: Text('${p.category} · \$${p.priceUsd.toStringAsFixed(2)}'),
                            onTap: () => Navigator.pop(context, p),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
