import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/key_stats_section.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/market_position_section.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/summary_section.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:provider/provider.dart';

import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/socket/stock_socket_manager.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/stock_detail_app_bar.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/section_nav_bar.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/detail_sections.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/price_section.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/input_section.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/section_detector.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/details_section.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/providers/scroll_sync_provider.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());

  late StockEntity _stock;
  late final StockSocketManager _socketManager;
  String? _subscribedStockCode;

  @override
  void initState() {
    super.initState();
    _socketManager = sl<StockSocketManager>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stockCode =
        GoRouterState.of(context).pathParameters['stockCode'] ?? '-';

    // Try to get from provider (cached)
    // Note: We use context.read because we don't want to rebuild the whole screen on every minor update
    // just for the initial setup. The specific sections listen to streams.
    final cachedStock = context.read<WatchlistProvider>().getPrice(stockCode);

    final newStock =
        cachedStock ??
        StockEntity(
          stockCode: stockCode,
          stockName: stockCode, // Temporary name until loaded
          currentPrice: 0,
          changeRate: 0,
          timestamp: DateTime.now(),
        );

    _stock = newStock;

    // Only subscribe if the stock code has changed
    if (_stock.stockCode != _subscribedStockCode) {
      if (_subscribedStockCode != null) {
        _socketManager.unsubscribeFromStock(_subscribedStockCode!);
      }
      _socketManager.subscribeToStock(
        _stock.stockCode,
        _stock.currentPrice.toDouble(),
      );
      _subscribedStockCode = _stock.stockCode;
    }
  }

  @override
  void dispose() {
    _socketManager.unsubscribeFromStock(_stock.stockCode);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    context.read<ScrollSyncProvider>().setTargetIndex(
      index,
      duration: const Duration(milliseconds: 300),
    );

    final key = _sectionKeys[index];
    final keyContext = key.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              StockDetailAppBar(stock: _stock),

              SliverPersistentHeader(
                pinned: true,
                delegate: SectionNavBarDelegate(
                  onTabTap: (index) async {
                    _scrollToIndex(index);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // 0: Price
                    SectionDetector(
                      index: 0,
                      child: Container(
                        key: _sectionKeys[0],
                        child: PriceSection(
                          initialStock: _stock,
                          priceStream: _socketManager.messageStream.where(
                            (m) => m.stockCode == _stock.stockCode,
                          ),
                        ),
                      ),
                    ),
                    const SectionDivider(),

                    // 1: Summary
                    SectionDetector(
                      index: 1,
                      child: Container(
                        key: _sectionKeys[1],
                        child: SummarySection(stock: _stock),
                      ),
                    ),
                    const SectionDivider(),

                    // 2: Input (Alerts)
                    SectionDetector(
                      index: 2,
                      child: Container(
                        key: _sectionKeys[2],
                        child: InputSection(),
                      ),
                    ),
                    const SectionDivider(),

                    // 3: Details
                    SectionDetector(
                      index: 3,
                      child: Container(
                        key: _sectionKeys[3],
                        child: const DetailsSection(),
                      ),
                    ),
                    const SectionDivider(),

                    // Key Stats Section (Added here)
                    SectionDetector(
                      index: 4,
                      child: Container(
                        key: _sectionKeys[4],
                        child: KeyStatsSection(stock: _stock),
                      ),
                    ),
                    const SectionDivider(),

                    // 5: Market Position
                    SectionDetector(
                      index: 5,
                      child: Container(
                        key: _sectionKeys[5],
                        child: MarketPositionSection(
                          rank: _stock.rank,
                          weight: _stock.marketWeight,
                        ),
                      ),
                    ),
                    Gap(200),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
