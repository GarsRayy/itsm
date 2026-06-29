import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../models/service_catalog.dart';
import '../repositories/catalog_repository.dart';

/// Browse all 11 service catalogs and their 51 sub-categories.
///
/// Provides a read-only reference view of the entire ITSM service
/// catalog tree. Useful for Leaders to understand the service scope.
class ServiceCatalogScreen extends ConsumerStatefulWidget {
  const ServiceCatalogScreen({super.key});

  @override
  ConsumerState<ServiceCatalogScreen> createState() =>
      _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends ConsumerState<ServiceCatalogScreen> {
  List<ServiceCatalog> _catalogs = [];
  final Map<int, List<ServiceItem>> _itemsMap = {};
  bool _isLoading = true;
  int? _expandedCatalogId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final catalogs = await repo.fetchCatalogs();
      setState(() {
        _catalogs = catalogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleExpand(int catalogId) async {
    if (_expandedCatalogId == catalogId) {
      setState(() => _expandedCatalogId = null);
      return;
    }

    // Load items if not cached
    if (!_itemsMap.containsKey(catalogId)) {
      try {
        final repo = ref.read(catalogRepositoryProvider);
        final items = await repo.fetchItemsByCatalog(catalogId);
        _itemsMap[catalogId] = items;
      } catch (_) {
        // Silent fail — show empty
      }
    }

    setState(() => _expandedCatalogId = catalogId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Service Catalog', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryYellow),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  itemCount: _catalogs.length,
                  itemBuilder: (context, index) {
                    final catalog = _catalogs[index];
                    final isExpanded = _expandedCatalogId == catalog.id;
                    final items = _itemsMap[catalog.id] ?? [];

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSizes.spacing12),
                      child: GlassmorphicContainer(
                        borderColor: isExpanded
                            ? AppColors.primaryYellow.withValues(alpha: 0.4)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Catalog header (tappable)
                            InkWell(
                              onTap: () => _toggleExpand(catalog.id),
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLarge),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    AppSizes.spacing16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryYellow
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppSizes.radiusMedium),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                            color:
                                                AppColors.primaryYellow,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppSizes.spacing12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catalog.name,
                                            style:
                                                AppTextStyles.titleMedium,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            catalog.provider,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.25 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Sub-items (expandable)
                            if (isExpanded && items.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSizes.spacing16,
                                  right: AppSizes.spacing16,
                                  bottom: AppSizes.spacing16,
                                ),
                                child: Column(
                                  children: [
                                    const Divider(
                                        color: AppColors.divider),
                                    const SizedBox(
                                        height: AppSizes.spacing8),
                                    ...items
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final item = entry.value;
                                      final isIncident =
                                          item.requestType == 'incident';
                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical:
                                                    AppSizes.spacing4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isIncident
                                                  ? Icons
                                                      .warning_amber_rounded
                                                  : Icons
                                                      .build_circle_outlined,
                                              size: AppSizes.iconSmall,
                                              color: isIncident
                                                  ? AppColors.accentRed
                                                  : AppColors.accentBlue,
                                            ),
                                            const SizedBox(
                                                width:
                                                    AppSizes.spacing8),
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: AppTextStyles
                                                    .bodyMedium
                                                    .copyWith(
                                                  color: AppColors
                                                      .textPrimary,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal:
                                                    AppSizes.spacing8,
                                                vertical:
                                                    AppSizes.spacing2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (isIncident
                                                        ? AppColors
                                                            .accentRed
                                                        : AppColors
                                                            .accentBlue)
                                                    .withValues(
                                                        alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes
                                                            .radiusFull),
                                              ),
                                              child: Text(
                                                isIncident
                                                    ? 'Incident'
                                                    : 'Request',
                                                style: AppTextStyles
                                                    .labelSmall
                                                    .copyWith(
                                                  color: isIncident
                                                      ? AppColors
                                                          .accentRed
                                                      : AppColors
                                                          .accentBlue,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate(
                                          delay:
                                              (entry.key * 50).ms)
                                        .fadeIn()
                                        .slideX(
                                            begin: -0.05, end: 0);
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ).animate(delay: (100 * (index % 10)).ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
        ),
      ),
    );
  }
}
