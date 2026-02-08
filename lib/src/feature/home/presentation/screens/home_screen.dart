import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/home/presentation/widgets/stock_list_tile.dart';
import 'package:lucy_assignment/src/feature/home/presentation/widgets/stock_search_bar.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/usecases/get_stocks_usecase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<StockEntity>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    // 데이터는 한 번만 로드하고, 필터링은 메모리 상에서 수행
    _stocksFuture = sl<GetStocksUseCase>().call();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          context.l10n.markets,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: CircleAvatar(
        //       backgroundColor: context.theme.brightness == Brightness.light
        //           ? AppColors.backgroundLight
        //           : AppColors.surfaceDark,
        //       radius: 16,
        //       // Placeholder for profile image
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // Search Bar
          StockSearchBar(controller: _searchController),

          // Stock List
          Expanded(
            child: FutureBuilder<List<StockEntity>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final allStocks = snapshot.data!;

                  // Filtering Logic
                  final filteredStocks = allStocks.where((stock) {
                    final query = _searchQuery.toLowerCase();
                    final name = stock.stockName?.toLowerCase() ?? "";
                    final code = stock.stockCode.toLowerCase();
                    return name.contains(query) || code.contains(query);
                  }).toList();

                  if (filteredStocks.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noResultsFound,
                        style: AppTypography.bodyLarge.copyWith(
                          color: context.theme.brightness == Brightness.light
                              ? AppColors.textPrimaryLight
                              : AppColors.textPrimaryDark,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredStocks.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: context.theme.brightness == Brightness.light
                          ? AppColors.borderDark.withValues(alpha: 0.5)
                          : AppColors.borderLight.withValues(alpha: 0.5),
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final stock = filteredStocks[index];
                      return StockListTile(
                        stock: stock,
                        searchQuery: _searchQuery, // For highlighting
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
