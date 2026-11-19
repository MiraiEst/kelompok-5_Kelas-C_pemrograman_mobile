import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions.dart';
import '../../core/result.dart';
import '../../domain/models/catalog_product.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import 'catalog_import_sheet.dart';

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _images = TextEditingController();
  final _start = TextEditingController();
  final _reserve = TextEditingController();
  final _buyNow = TextEditingController();
  final _shipping = TextEditingController(text: '0');

  String? _category;
  ItemCondition _condition = ItemCondition.used;
  AuctionDuration _duration = AuctionDuration.sevenDays;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _description, _images, _start, _reserve, _buyNow, _shipping]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _money(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp(r'[^0-9]'), ''));

  List<String> get _imageUrls => _images.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.startsWith('http'))
      .toList();

  Future<void> _importFromCatalog() async {
    final product = await showModalBottomSheet<CatalogProduct>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CatalogImportSheet(),
    );
    if (product == null || !mounted) return;

    setState(() {
      _title.text = product.title;
      _description.text = product.description;
      _category = product.category;
      _images.text = (product.images.isEmpty ? [product.thumbnail] : product.images).join('\n');
    });

    // Suggest a starting price: half the catalog price, USD -> IDR (Frankfurter).
    // Result<T> (sealed class) instead of try/catch.
    final result = await Result.guard(
      () => ref.read(currencyApiProvider).usdToIdr(product.priceUsd * 0.5),
    );
    if (!mounted) return;
    switch (result) {
      case Ok(value: final idr):
        final rounded = (idr / 1000).round() * 1000;
        setState(() => _start.text = '${rounded < 1000 ? 1000 : rounded}');
      case Err():
        showSnack(context, 'Exchange rate unavailable. Enter the starting price yourself.');
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final id = await ref.read(listingRepositoryProvider).createListing(
            NewListing(
              title: _title.text.trim(),
              description: _description.text.trim(),
              category: _category ?? 'other',
              condition: _condition,
              imageUrls: _imageUrls,
              startPrice: _money(_start)!,
              reservePrice: _reserve.text.nullIfBlank == null ? null : _money(_reserve),
              buyNowPrice: _buyNow.text.nullIfBlank == null ? null : _money(_buyNow),
              shippingCost: _money(_shipping) ?? 0,
              duration: _duration,
            ),
            user,
          );
      if (mounted) context.pushReplacement('/listing/$id');
    } catch (e) {
      if (mounted) showSnack(context, 'Could not create listing: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final categoryItems = <String, String>{
      ?_category: _category!, // imported category not in list
      for (final c in categories) c.slug: c.name,
    };

    InputDecoration money(String label, {String? helper}) =>
        InputDecoration(labelText: label, prefixText: 'Rp ', helperText: helper);

    return Scaffold(
      appBar: AppBar(title: const Text('Sell an item')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: _importFromCatalog,
              icon: const Icon(Icons.travel_explore),
              label: const Text('Import from catalog (DummyJSON)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 80,
              validator: (v) => (v == null || v.trim().length < 3) ? 'Enter a title' : null,
            ),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(_category), // rebuild when a catalog import sets it
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final e in categoryItems.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Pick a category' : null,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ItemCondition>(
              segments: [
                for (final c in ItemCondition.values)
                  ButtonSegment(value: c, label: Text(c.label)),
              ],
              selected: {_condition},
              onSelectionChanged: (s) => setState(() => _condition = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _images,
              decoration: const InputDecoration(
                labelText: 'Photo URLs (one per line, max 12)',
                helperText: 'Imported automatically from the catalog',
              ),
              maxLines: 3,
              validator: (_) => _imageUrls.length > 12 ? 'Maximum 12 photos' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _start,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: money('Starting price'),
              validator: (_) {
                final v = _money(_start);
                return (v == null || v < 1000) ? 'At least Rp 1.000' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reserve,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: money('Reserve price (optional)', helper: 'Hidden minimum price'),
              validator: (_) {
                if (_reserve.text.isEmpty) return null;
                final r = _money(_reserve), s = _money(_start);
                return (r == null || s == null || r <= s) ? 'Must be higher than the starting price' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _buyNow,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: money('Buy It Now price (optional)'),
              validator: (_) {
                if (_buyNow.text.isEmpty) return null;
                final b = _money(_buyNow), s = _money(_start), r = _money(_reserve);
                if (b == null || s == null || b <= s) return 'Must be higher than the starting price';
                if (r != null && b < r) return 'Must be at least the reserve price';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shipping,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: money('Shipping cost', helper: '0 = free shipping'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AuctionDuration>(
              initialValue: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: [
                for (final d in AuctionDuration.values)
                  DropdownMenuItem(value: d, child: Text(d.label)),
              ],
              onChanged: (v) => setState(() => _duration = v ?? _duration),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('List item'),
            ),
          ],
        ),
      ),
    );
  }
}
