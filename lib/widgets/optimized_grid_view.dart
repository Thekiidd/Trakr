class OptimizedGridView extends StatefulWidget {
  final List<Game> games;
  final Function(Game) onGameTap;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  const OptimizedGridView({
    Key? key,
    required this.games,
    required this.onGameTap,
    required this.onRefresh,
    required this.onLoadMore,
  }) : super(key: key);

  @override
  State<OptimizedGridView> createState() => _OptimizedGridViewState();
}

class _OptimizedGridViewState extends State<OptimizedGridView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await widget.onLoadMore();
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 300,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.games.length + (_isLoadingMore ? 1 : 0),
        cacheExtent: 500, // Aumentar cache para scroll suave
        itemBuilder: (context, index) {
          if (index >= widget.games.length) {
            return Center(child: CircularProgressIndicator());
          }
          return GameCard(
            game: widget.games[index],
            onTap: () => widget.onGameTap(widget.games[index]),
            onFavorite: () {}, // Implementar según necesidad
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 