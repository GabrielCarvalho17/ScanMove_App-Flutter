import 'package:flutter/material.dart';
import 'search_bar.dart'; // Certifique-se de importar o CustomSearchBar

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;
  final Widget? customLeading; // Novo parâmetro para aceitar um botão customizado
  final bool showLeading;
  final bool showSearchIcon;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onSearchOpen;
  final VoidCallback? onSearchClose;
  final ValueChanged<String>? onSearchChanged;
  final double customHeight;
  final bool showDrawerIcon; // Controla a exibição do ícone do drawer

  const CustomAppBar({
    Key? key,
    required this.titleText,
    this.actions,
    this.customLeading,
    this.showLeading = true,
    this.showSearchIcon = true,
    this.bottom,
    this.onSearchOpen,
    this.onSearchClose,
    this.onSearchChanged,
    this.customHeight = kToolbarHeight,
    this.showDrawerIcon = true, // Valor padrão para mostrar o ícone do drawer
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(customHeight + (bottom?.preferredSize.height ?? 0.0));
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: AppBar(
        titleSpacing: 0, // Define o espaçamento do título para zero
        leading: _isSearching
            ? null
            : (widget.showLeading
            ? (widget.customLeading ?? Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ))
            : null),
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Espaçamento padrão entre o título e o leading
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isSearching
                ? CustomSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onClose: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                  if (widget.onSearchClose != null) {
                    widget.onSearchClose!();
                  }
                });
              },
              onSearchChanged: widget.onSearchChanged ?? (value) {},
            )
                : Text(
              widget.titleText,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (!_isSearching && widget.showSearchIcon)
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                  if (widget.onSearchOpen != null) {
                    widget.onSearchOpen!();
                  }
                });
              },
            ),
          if (!_isSearching) ...?widget.actions,
        ],
        automaticallyImplyLeading: false, // Controla manualmente o leading
        bottom: widget.bottom,
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
