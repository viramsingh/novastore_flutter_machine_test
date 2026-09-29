import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(productsProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    ref.read(productsProvider.notifier).search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search products, brands, tech...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(productsProvider.notifier).search('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: _onSearchSubmitted,
          textInputAction: TextInputAction.search,
        ),
      ),
      body: productsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsState.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 14),
                      Text(
                        'No products found for "${productsState.searchQuery}"',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Try searching for laptops, shoes, beauty or phone'),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Found ${productsState.total} matching items',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
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
                            return ProductCard(product: productsState.products[index]);
                          },
                          childCount: productsState.products.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 110), // Padding for dock
                    ),
                  ],
                ),
    );
  }
}
