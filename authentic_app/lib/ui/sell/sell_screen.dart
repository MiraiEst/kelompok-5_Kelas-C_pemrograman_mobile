import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config.dart';
import '../../core/result.dart';
import '../../domain/models/catalog_product.dart';
import '../../domain/models/listing.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../providers/providers.dart';
import '../listing/listing_detail_screen.dart' show endDateFormat;
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/segmented_tabs.dart';
import 'catalog_import_sheet.dart';
import 'sell_validation.dart';
import '../../domain/models/item_category.dart';
import '../widgets/brand_form_theme.dart';

/// A photo in the form: picked on this device, or already online.
sealed class SellPhoto {
  const SellPhoto();
}

final class LocalPhoto extends SellPhoto {
  LocalPhoto(this.bytes);
  final Uint8List bytes;
}

final class RemotePhoto extends SellPhoto {
  const RemotePhoto(this.url);
  final String url;
}

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _start = TextEditingController();
  final _reserve = TextEditingController();
  final _buyNow = TextEditingController();
  final _shipping = TextEditingController();
  final _location = TextEditingController();

  // Section keys, in screen order, for "scroll to the first error".
  final _photosKey = GlobalKey();
  final _titleKey = GlobalKey();
  final _categoryKey = GlobalKey();
  final _pricesKey = GlobalKey();
  final _reserveKey = GlobalKey();

  late String _listingId = ref.read(listingRepositoryProvider).newListingId();
  final List<SellPhoto> _photos = [];
  final Map<SellPhoto, double> _progress = {};
  SellError? _photoError;
  String? _category;
  ItemCondition _condition = ItemCondition.used;
  ListingFormat _format = ListingFormat.auction;
  AuctionDuration _duration = AuctionDuration.sevenDays;
  int _handlingDays = 2;
  bool _acceptsReturns = false;
  bool _busy = false;
  bool _savingDraft = false;
  bool _dirty = false;
  bool _submitted = false;

  List<TextEditingController> get _controllers => [
    _title,
    _description,
    _start,
    _reserve,
    _buyNow,
    _shipping,
    _location,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_markDirty);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerDraft());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  // ---------------------------------------------------------------- drafts

  Future<void> _offerDraft() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    final repo = ref.read(listingRepositoryProvider);
    final draft = await Result.guard(() => repo.latestDraft(uid));
    final found = draft.valueOrNull;
    if (found == null || !mounted) return;
    final (id, data) = found;
    final resume = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.continueDraftQ),
        content: Text(context.l10n.draftSavedAs('${data['title'] ?? context.l10n.untitled}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.startNew),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.continueLabel),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (resume == true) {
      _loadDraft(id, data);
    } else {
      await repo.deleteDraft(uid, id);
    }
  }

  void _loadDraft(String id, Map<String, dynamic> d) {
    String money(Object? v) => v is num ? formatThousands(v.toInt()) : '';
    setState(() {
      _listingId = id;
      _title.text = d['title'] as String? ?? '';
      _description.text = d['description'] as String? ?? '';
      _category = ItemCategory.tryParse(d['category'])?.slug;
      _condition = ItemCondition.parse(d['condition']);
      _format = ListingFormat.parse(d['format']);
      _start.text = money(d['startPrice']);
      _reserve.text = money(d['reservePrice']);
      _buyNow.text = money(d['buyNowPrice']);
      _shipping.text = money(d['shippingCost']);
      _location.text = d['location'] as String? ?? '';
      _handlingDays = (d['handlingDays'] as num?)?.toInt() ?? 2;
      _acceptsReturns = d['acceptsReturns'] as bool? ?? false;
      _duration = AuctionDuration.values.firstWhere(
        (x) => x.name == d['duration'],
        orElse: () => AuctionDuration.sevenDays,
      );
      _photos
        ..clear()
        ..addAll([for (final u in (d['imageUrls'] as List? ?? const [])) RemotePhoto('$u')]);
      _dirty = false;
    });
  }

  Future<void> _saveDraft() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    setState(() => _savingDraft = true);
    try {
      final urls = await _uploadPhotos(uid);
      await ref.read(listingRepositoryProvider).saveDraft(uid, _listingId, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'category': _category,
        'condition': _condition.value,
        'format': _format.value,
        'startPrice': parseMoney(_start.text),
        'reservePrice': parseMoney(_reserve.text),
        'buyNowPrice': parseMoney(_buyNow.text),
        'shippingCost': parseMoney(_shipping.text),
        'location': _location.text.trim(),
        'handlingDays': _handlingDays,
        'acceptsReturns': _acceptsReturns,
        'duration': _duration.name,
        'imageUrls': urls,
      });
      if (!mounted) return;
      setState(() => _dirty = false);
      showSnack(context, context.l10n.draftSaved);
    } catch (e) {
      if (mounted) showSnack(context, context.l10n.couldNotSaveDraft(friendlyError(e)));
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  // ---------------------------------------------------------------- photos

  Future<void> _addPhotos() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final room = AppConfig.maxPhotos - _photos.length;
    final files = source == ImageSource.camera
        ? [
            ?await picker.pickImage(
              source: source,
              maxWidth: 1600,
              maxHeight: 1600,
              imageQuality: 80,
            ),
          ]
        : await picker.pickMultiImage(
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 80,
            limit: room,
          );
    if (files.isEmpty) return;
    final added = <SellPhoto>[for (final f in files.take(room)) LocalPhoto(await f.readAsBytes())];
    if (!mounted) return;
    setState(() {
      _photos.addAll(added);
      _dirty = true;
      if (_submitted) _photoError = SellValidation.photos(_photos.length);
    });
    if (files.length > room) showSnack(context, context.l10n.onlyNPhotos(AppConfig.maxPhotos));
  }

  void _removePhoto(SellPhoto p) => setState(() {
    _photos.remove(p);
    _dirty = true;
    if (_submitted) _photoError = SellValidation.photos(_photos.length);
  });

  void _movePhoto(int from, int to) => setState(() {
    final p = _photos.removeAt(from);
    _photos.insert(to.clamp(0, _photos.length), p);
    _dirty = true;
  });

  /// Uploads local photos (in order) and returns all URLs.
  Future<List<String>> _uploadPhotos(String uid) async {
    final storage = ref.read(storageRepositoryProvider);
    final urls = <String>[];
    for (var i = 0; i < _photos.length; i++) {
      final photo = _photos[i];
      switch (photo) {
        case RemotePhoto(:final url):
          urls.add(url);
        case LocalPhoto(:final bytes):
          setState(() => _progress[photo] = 0);
          final url = await storage.uploadListingPhoto(
            uid: uid,
            listingId: _listingId,
            index: i,
            bytes: bytes,
            onProgress: (p) {
              if (mounted) setState(() => _progress[photo] = p);
            },
          );
          final remote = RemotePhoto(url);
          if (mounted) {
            setState(() {
              _progress.remove(photo);
              _photos[i] = remote;
            });
          }
          urls.add(url);
      }
    }
    return urls;
  }

  // ---------------------------------------------------------------- import

  Future<void> _importFromCatalog() async {
    final product = await showModalBottomSheet<CatalogProduct>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CatalogImportSheet(),
    );
    if (product == null || !mounted) return;

    final images = product.images.isEmpty ? [product.thumbnail] : product.images;
    setState(() {
      _title.text = product.title.length > 80 ? product.title.substring(0, 80) : product.title;
      _description.text = product.description;
      _category = ItemCategory.parse(product.category).slug;
      _photos.addAll(images.take(AppConfig.maxPhotos - _photos.length).map((u) => RemotePhoto(u)));
    });

    // Suggest a starting price: half the catalog price, USD -> IDR (Frankfurter).
    final result = await Result.guard(
      () => ref.read(currencyApiProvider).usdToIdr(product.priceUsd * 0.5),
    );
    if (!mounted) return;
    switch (result) {
      case Ok(value: final idr):
        final rounded = (idr / 1000).round() * 1000;
        _start.text = formatThousands(rounded < 1000 ? 1000 : rounded);
      case Err():
        showSnack(context, context.l10n.rateUnavailable);
    }
  }

  // ---------------------------------------------------------------- submit

  /// Returns the key of the first invalid section, or null when valid.
  GlobalKey? _firstError() {
    final start = parseMoney(_start.text);
    final reserve = parseMoney(_reserve.text);
    final buyNow = parseMoney(_buyNow.text);
    if (SellValidation.photos(_photos.length) != null) return _photosKey;
    if (SellValidation.title(_title.text) != null) return _titleKey;
    if (SellValidation.category(_category) != null) return _categoryKey;
    if (SellValidation.startPrice(_format, start) != null ||
        SellValidation.buyNowPrice(_format, start, reserve, buyNow) != null) {
      return _pricesKey;
    }
    if (SellValidation.reservePrice(_format, start, reserve) != null) return _reserveKey;
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _photoError = SellValidation.photos(_photos.length);
    });
    final formOk = _form.currentState!.validate();
    final first = _firstError();
    if (!formOk || first != null) {
      final ctx = (first ?? _titleKey).currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
      return;
    }
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final urls = await _uploadPhotos(user.uid);
      final repo = ref.read(listingRepositoryProvider);
      final id = await repo.createListing(
        NewListing(
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category!,
          condition: _condition,
          imageUrls: urls,
          startPrice: parseMoney(_start.text) ?? parseMoney(_buyNow.text) ?? 0,
          reservePrice: parseMoney(_reserve.text),
          buyNowPrice: parseMoney(_buyNow.text),
          shippingCost: parseMoney(_shipping.text) ?? 0,
          duration: _duration,
          format: _format,
          handlingDays: _handlingDays,
          location: _location.text.trim(),
          acceptsReturns: _acceptsReturns,
          returnDays: 7,
        ),
        user,
        id: _listingId,
      );
      await Result.guard(() => repo.deleteDraft(user.uid, _listingId));
      _dirty = false;
      if (mounted) context.pushReplacement('/listing/$id');
    } catch (e) {
      if (mounted) showSnack(context, context.l10n.couldNotCreateListing(friendlyError(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.discardQ),
        content: Text(context.l10n.discardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.keepEditing),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.discard)),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _close() async {
    if (await _confirmDiscard() && mounted) {
      _dirty = false;
      context.pop();
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final start = parseMoney(_start.text);
    final reserve = parseMoney(_reserve.text);
    final buyNow = parseMoney(_buyNow.text);
    final durations = [
      for (final d in AuctionDuration.values)
        if (d != AuctionDuration.fiveMinutesTest || kDebugMode) d,
    ];

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: context.l10n.close,
            icon: const Icon(Icons.close, color: AppColors.ocean, size: 30),
            onPressed: _close,
          ),
          titleSpacing: 0,
          title: Text(
            context.l10n.sellAnItem,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBright,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandBright,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _savingDraft || _busy ? null : _saveDraft,
              child: _savingDraft
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.saveDraft),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: BrandFormTheme(
          child: Form(
            key: _form,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                SecondaryButton(
                  color: AppColors.ocean,
                  label: context.l10n.importFromCatalog,
                  icon: Icons.travel_explore,
                  dashed: true,
                  onPressed: _importFromCatalog,
                ),
                const SizedBox(height: 24),
                _PhotoGrid(
                  key: _photosKey,
                  photos: _photos,
                  progress: _progress,
                  error: _photoError?.text(context),
                  onAdd: _photos.length >= AppConfig.maxPhotos || _busy ? null : _addPhotos,
                  onRemove: _busy ? null : _removePhoto,
                  onMove: _movePhoto,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  key: _titleKey,
                  label: context.l10n.title,
                  controller: _title,
                  hint: context.l10n.titleHint,
                  maxLength: 80,
                  validator: (v) => SellValidation.title(v ?? '')?.text(context),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: context.l10n.description,
                  controller: _description,
                  hint: context.l10n.descriptionHint,
                  maxLines: 3,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                Column(
                  key: _categoryKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.category, style: brandFieldLabel),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_category),
                      initialValue: _category,
                      isExpanded: true,
                      hint: Text(context.l10n.chooseCategory),
                      items: [
                        for (final c in ItemCategory.values)
                          DropdownMenuItem(value: c.slug, child: Text(c.text(context))),
                      ],
                      onChanged: (v) => setState(() {
                        _category = v;
                        _dirty = true;
                      }),
                      validator: (v) => SellValidation.category(v)?.text(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(context.l10n.condition, style: brandFieldLabel),
                const SizedBox(height: 8),
                SegmentedTabs<ItemCondition>(
                  values: ItemCondition.values,
                  selected: _condition,
                  label: (c) => c.text(context),
                  onChanged: (c) => setState(() {
                    _condition = c;
                    _dirty = true;
                  }),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.format, style: brandFieldLabel),
                const SizedBox(height: 8),
                SegmentedTabs<ListingFormat>(
                  values: ListingFormat.values,
                  selected: _format,
                  label: (f) => f.text(context),
                  onChanged: (f) => setState(() {
                    _format = f;
                    _dirty = true;
                  }),
                ),
                if (_format == ListingFormat.buyNow) ...[
                  const SizedBox(height: 6),
                  Text(context.l10n.buyNowOnlyNote, style: AppText.caption),
                ],
                const SizedBox(height: 16),
                Row(
                  key: _pricesKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_format.hasAuction)
                      Expanded(
                        child: AppTextField(
                          label: context.l10n.startingPrice,
                          controller: _start,
                          rupiah: true,
                          validator: (_) =>
                              SellValidation.startPrice(_format, start)?.text(context),
                        ),
                      ),
                    if (_format == ListingFormat.both) const SizedBox(width: 12),
                    if (_format.hasBuyNow)
                      Expanded(
                        child: AppTextField(
                          label: context.l10n.buyItNow,
                          controller: _buyNow,
                          rupiah: true,
                          validator: (_) => SellValidation.buyNowPrice(
                            _format,
                            start,
                            reserve,
                            buyNow,
                          )?.text(context),
                        ),
                      ),
                  ],
                ),
                if (_format.hasAuction) ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    key: _reserveKey,
                    label: context.l10n.reservePrice,
                    labelSuffix: context.l10n.optionalHidden,
                    controller: _reserve,
                    rupiah: true,
                    helper: context.l10n.reserveHelper,
                    validator: (_) =>
                        SellValidation.reservePrice(_format, start, reserve)?.text(context),
                  ),
                ],
                const SizedBox(height: 16),
                Text(context.l10n.duration, style: brandFieldLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in durations)
                      ChoiceChip(
                        label: Text(d.text(context)),
                        selected: d == _duration,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onSelected: (_) => setState(() {
                          _duration = d;
                          _dirty = true;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.endsOn(endDateFormat.format(DateTime.now().add(_duration.duration))),
                  style: AppText.caption,
                ),
                const SizedBox(height: 28),
                SectionHeader(context.l10n.shippingAndReturns),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: context.l10n.shippingCost,
                        controller: _shipping,
                        rupiah: true,
                        hint: context.l10n.zeroFree,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.shipsWithin, style: AppText.fieldLabel),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _handlingDays,
                            isExpanded: true,
                            items: [
                              for (final d in const [1, 2, 3, 5])
                                DropdownMenuItem(value: d, child: Text(context.l10n.nDays(d))),
                            ],
                            onChanged: (v) => setState(() {
                              _handlingDays = v ?? _handlingDays;
                              _dirty = true;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: context.l10n.itemLocation,
                  controller: _location,
                  hint: context.l10n.itemLocationHint,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.l10n.acceptReturns,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(context.l10n.within7Days, style: AppText.caption),
                  value: _acceptsReturns,
                  onChanged: (v) => setState(() {
                    _acceptsReturns = v;
                    _dirty = true;
                  }),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    color: AppColors.ocean,
                    label: context.l10n.listItem,
                    loading: _busy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.finalValueFee(AppConfig.finalValueFeePercent),
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Photos 3 / 12" + 4-column grid: add tile first, then photos.
/// Long-press a photo and drag it to reorder; the first photo is the cover.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    super.key,
    required this.photos,
    required this.progress,
    required this.error,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
  });

  final List<SellPhoto> photos;
  final Map<SellPhoto, double> progress;
  final String? error;
  final VoidCallback? onAdd;
  final void Function(SellPhoto)? onRemove;
  final void Function(int from, int to) onMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(context.l10n.photos, style: AppText.sectionTitle)),
            Text('${photos.length} / ${AppConfig.maxPhotos}', style: AppText.meta),
          ],
        ),
        const SizedBox(height: 4),
        Text(context.l10n.reorderHint, style: AppText.caption),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            Semantics(
              button: true,
              label: context.l10n.addPhotos,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(AppRadius.photo),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    radius: AppRadius.photo,
                    color: error != null ? AppColors.error : AppColors.fieldBorder,
                    strokeWidth: 2,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: onAdd == null ? AppColors.line : AppColors.fieldBorder,
                    ),
                  ),
                ),
              ),
            ),
            for (var i = 0; i < photos.length; i++)
              _PhotoTile(
                index: i,
                photo: photos[i],
                progress: progress[photos[i]],
                onRemove: onRemove,
                onMove: onMove,
              ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.index,
    required this.photo,
    required this.progress,
    required this.onRemove,
    required this.onMove,
  });

  final int index;
  final SellPhoto photo;
  final double? progress;
  final void Function(SellPhoto)? onRemove;
  final void Function(int from, int to) onMove;

  Widget _image() {
    final r = BorderRadius.circular(AppRadius.photo);
    return switch (photo) {
      LocalPhoto(:final bytes) => ClipRRect(
        borderRadius: r,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
      RemotePhoto(:final url) => ListingImage(
        url: url,
        width: double.infinity,
        height: double.infinity,
        borderRadius: r,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tile = Stack(
      fit: StackFit.expand,
      children: [
        _image(),
        if (index == 0)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                context.l10n.cover,
                style: const TextStyle(
                  color: AppColors.onInk,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (progress != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.photo),
            child: ColoredBox(
              color: AppColors.photoOverlay,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: progress == 0 ? null : progress,
                    strokeWidth: 3,
                    color: AppColors.onInk,
                    semanticsLabel: context.l10n.uploadingPhoto(index + 1),
                  ),
                ),
              ),
            ),
          ),
        if (onRemove != null && progress == null)
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              tooltip: context.l10n.removePhotoN(index + 1),
              onPressed: () => onRemove!(photo),
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: AppColors.onInk),
              ),
            ),
          ),
      ],
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != index,
      onAcceptWithDetails: (d) => onMove(d.data, index),
      builder: (context, candidates, _) => LongPressDraggable<int>(
        data: index,
        feedback: SizedBox(width: 72, height: 72, child: Opacity(opacity: 0.85, child: _image())),
        childWhenDragging: Opacity(opacity: 0.3, child: tile),
        child: Semantics(
          label: index == 0 ? context.l10n.photo1Cover : context.l10n.photoN(index + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.photo),
              border: Border.all(
                color: candidates.isNotEmpty ? AppColors.ink : Colors.transparent,
                width: 2,
              ),
            ),
            child: tile,
          ),
        ),
      ),
    );
  }
}
