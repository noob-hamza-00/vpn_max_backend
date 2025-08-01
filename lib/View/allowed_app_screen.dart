import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/apps_provider.dart';

class AllowedAppsScreen extends StatefulWidget {
  const AllowedAppsScreen({super.key});

  @override
  State<AllowedAppsScreen> createState() => _AllowedAppsScreenState();
}

class _AllowedAppsScreenState extends State<AllowedAppsScreen> {
  MethodChannel platform = const MethodChannel("disallowList");

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _filteredApps = [];
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredApps();
    });
  }

  void _updateFilteredApps() {
    final apps = Provider.of<AppsProvider>(context, listen: false).getAllApps;

    if (_searchQuery.isEmpty) {
      _filteredApps = List.from(apps);
    } else {
      _filteredApps = apps.where((app) {
        final appName = app.app.name.toLowerCase();
        final packageName = app.app.packageName.toLowerCase();
        final searchTerm = _searchQuery.toLowerCase();

        // Search in both app name and package name for better results
        return appName.contains(searchTerm) || packageName.contains(searchTerm);
      }).toList();

      // Sort filtered results by relevance (exact matches first, then contains)
      _filteredApps.sort((a, b) {
        final aName = a.app.name?.toLowerCase() ?? '';
        final bName = b.app.name?.toLowerCase() ?? '';
        final searchTerm = _searchQuery.toLowerCase();

        // Exact matches first
        if (aName.startsWith(searchTerm) && !bName.startsWith(searchTerm)) return -1;
        if (!aName.startsWith(searchTerm) && bName.startsWith(searchTerm)) return 1;

        // Then alphabetical order
        return aName.compareTo(bName);
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
        _updateFilteredApps();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _updateFilteredApps();
    });
  }

  void _disallowApp(String packageName) async {
    await platform.invokeMethod("applyChanges", {"packageName": packageName});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppsProvider>(
      builder: (context, appsProvider, child) {
        final allApps = appsProvider.getAllApps;
        final isLoading = appsProvider.isLoading;

        // Update filtered apps when apps data changes
        if (_filteredApps.isEmpty && allApps.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _updateFilteredApps();
            });
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(7),
                    bottomLeft: Radius.circular(7)
                )
            ),
            backgroundColor: Colors.grey.shade900,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: _isSearchActive
                ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                border: InputBorder.none,
                // suffixIcon: _searchQuery.isNotEmpty
                //     ? IconButton(
                //   onPressed: _clearSearch,
                //   icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                // )
                //     : null,
              ),
            )
                : Text(
              'Allowed apps',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(
                  _isSearchActive ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search results counter
              if (_isSearchActive && _searchQuery.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey.shade800,
                  child: Text(
                    '${_filteredApps.length} app${_filteredApps.length != 1 ? 's' : ''} found',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Apps list
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                    : _filteredApps.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty ? Icons.apps : Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "No Apps Found!"
                            : "No apps match '$_searchQuery'",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearSearch,
                          child: Text(
                            'Clear search',
                            style: GoogleFonts.poppins(color: Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    await appsProvider.getAllApps;
                    _updateFilteredApps();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundImage: MemoryImage(app.app.icon!),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          title: Text(
                            app.app.name!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            app.app.packageName ?? '',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Switch(
                            activeColor: Colors.blue,
                            inactiveThumbColor: Colors.grey.shade600,
                            inactiveTrackColor: Colors.grey.shade800,
                            value: app.isSelected,
                            onChanged: (bool val) {
                              setState(() {
                                app.isSelected = val;
                                appsProvider.updateAppsList(
                                    app.app.packageName!,
                                    app.isSelected
                                );
                              });
                              _disallowApp(app.app.packageName!);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}