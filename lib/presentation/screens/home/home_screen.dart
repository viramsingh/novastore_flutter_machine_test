import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_list_tile.dart';
import '../../widgets/sliver_category_header.dart';
import '../../widgets/sliver_section_header.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(productsProvider.notifier).fetchMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsState = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final allProducts = productsState.products;
    // Split into 2-column SliverGrid items and SliverList items
    // First 6-8 items for 2-column grid, remainder for SliverList
    final gridItems = allProducts.take(8).toList();
    final listItems = allProducts.skip(8).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productsProvider.notifier).refresh();
        },
        edgeOffset: 120,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          // Physics providing snappy, jank-free scrolling
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ==========================================
            // Task 1 Requirement 1: Collapsing SliverAppBar
            // Pinned: true, Floating: true, Snap: true
            // With rich background banner and search bar
            // ==========================================
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 220.0,
              elevation: 0,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: const Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'NovaStore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner Image
                    Image.network(
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=1200&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isDark ? const Color(0xFF1E1B4B) : const Color(0xFF4F46E5),
                              isDark ? const Color(0xFF0F172A) : const Color(0xFF312E81),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay for smooth readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.75),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Promotional banner caption inside expanded area
                    Positioned(
                      left: 16,
                      bottom: 50,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SPRING SALE • UP TO 50% OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Discover Curated Premium Finds',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search products',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: () => ref.read(productsProvider.notifier).refresh(),
                ),
              ],
            ),

            // ==========================================
            // Task 1 Requirement 2: Sticky SliverPersistentHeader
            // Sticky category filter whose color/size changes using shrinkOffset
            // ==========================================
            categoriesAsync.when(
              data: (categories) => SliverPersistentHeader(
                pinned: true,
                delegate: SliverCategoryHeaderDelegate(
                  categories: categories,
                  selectedCategory: productsState.selectedCategory,
                  onCategorySelected: (cat) {
                    ref.read(productsProvider.notifier).selectCategory(cat);
                  },
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
              error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Section 1 Header: Featured Products Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productsState.selectedCategory != null
                              ? '${productsState.selectedCategory!.toUpperCase()} SPOTLIGHT'
                              : 'FEATURED SELECTIONS',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Top rated items handpicked for you',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // Task 1 Requirement 3: SliverGrid Section (2 Columns)
            // ==========================================
            if (productsState.isLoading && allProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text('Loading catalog...'),
                    ],
                  ),
                ),
              )
            else if (productsState.errorMessage != null && allProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(productsState.errorMessage!),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => ref.read(productsProvider.notifier).refresh(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = gridItems[index];
                      return ProductCard(product: product);
                    },
                    childCount: gridItems.length,
                  ),
                ),
              ),

            // ==========================================
            // Task 1 Bonus: Second Sticky SliverPersistentHeader
            // Pushes the category header or pins right below it!
            // ==========================================
            if (listItems.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverSectionHeaderDelegate(
                  title: 'Recommended Deals',
                  subtitle: 'Explore full catalog with instant savings',
                  icon: Icons.local_fire_department_rounded,
                  count: listItems.length,
                ),
              ),

            // ==========================================
            // Task 1 Requirement 4: SliverList Section
            // Combined with grid makes > 30 items total lazy rendered!
            // ==========================================
            if (listItems.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = listItems[index];
                    return ProductListTile(
                      product: product,
                      index: index,
                    );
                  },
                  childCount: listItems.length,
                ),
              ),

            // Loading More indicator at bottom of CustomScrollView
            if (productsState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            // ==========================================
            // Task 2 Integration requirement:
            // "The dock must not cover content (add proper bottom padding to the scroll view)"
            // ==========================================
            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
    );
  }
}
