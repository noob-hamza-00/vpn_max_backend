import 'package:flutter/material.dart';
import 'dart:convert';
import '../Model/vpn_server.dart';
import '../utils/preferences.dart';

class ServersProvider with ChangeNotifier {
  int selectedIndex = 0;
  VpnServer? _selectedServer;
  String selectedTab = "free";
  List<VpnServer> _freeServers = [];
  List<VpnServer> _proServers = [];
  bool _isInitialized = false;
  bool _hasPreferenceServer = false;

  // Keys for SharedPreferences
  static const String _selectedServerKey = 'selected_server';
  static const String _selectedIndexKey = 'selected_index';
  static const String _selectedTabKey = 'selected_tab';

  // Getters
  VpnServer? get selectedServer => _selectedServer;
  List<VpnServer> get freeServers => _freeServers;
  List<VpnServer> get proServers => _proServers;
  bool get isInitialized => _isInitialized;
  bool get hasPreferenceServer => _hasPreferenceServer;

  int getSelectedIndex() => selectedIndex;
  String getSelectedTab() => selectedTab;

  // Initialize provider and load saved data
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadSelectedServer();
    _isInitialized = true;
    notifyListeners();
  }


  // Load selected server from SharedPreferences
  Future<void> _loadSelectedServer() async {
    try {
      final serverJson = Prefs.getString(_selectedServerKey);
      final savedIndex = Prefs.getInt(_selectedIndexKey) ?? 0;
      final savedTab = Prefs.getString(_selectedTabKey) ?? "free";

      if (serverJson != null && serverJson.isNotEmpty) {
        final serverData = json.decode(serverJson);
        _selectedServer = VpnServer.fromJson(serverData);
        selectedIndex = savedIndex;
        selectedTab = savedTab;
        _hasPreferenceServer = true;
        debugPrint('Loaded saved server: ${_selectedServer!.country}');
      } else {
        debugPrint('No saved server found in preferences');
        _selectedServer = null;
        _hasPreferenceServer = false;
      }
    } catch (e) {
      debugPrint('Error loading selected server: $e');
      _selectedServer = null;
      _hasPreferenceServer = false;
    }
  }

  // Save selected server to SharedPreferences
  Future<void> _saveSelectedServer() async {
    try {
      if (_selectedServer != null) {
        await Prefs.setString(_selectedServerKey, json.encode(_selectedServer!.toJson()));
        await Prefs.setInt(_selectedIndexKey, selectedIndex);
        await Prefs.setString(_selectedTabKey, selectedTab);
        _hasPreferenceServer = true;
        debugPrint('Saved server: ${_selectedServer!.country}');
      }
    } catch (e) {
      debugPrint('Error saving selected server: $e');
    }
  }

  // Set selected server and save to storage
  void setSelectedServer(VpnServer server) {
    _selectedServer = server;
    _hasPreferenceServer = true;
    _saveSelectedServer();
    notifyListeners();
  }

  // Set selected index and save to storage
  void setSelectedIndex(int index) {
    selectedIndex = index;
    if (selectedTab == "free" && index >= 0 && index < _freeServers.length) {
      _selectedServer = _freeServers[index];
      _hasPreferenceServer = true;
      _saveSelectedServer();
    } else if (selectedTab == "pro" && index >= 0 && index < _proServers.length) {
      _selectedServer = _proServers[index];
      _hasPreferenceServer = true;
      _saveSelectedServer();
    }
    notifyListeners();
  }

  // Set selected tab and save to storage
  void setSelectedTab(String tab) {
    selectedTab = tab;
    if (_selectedServer != null) {
      _saveSelectedServer();
    }
    notifyListeners();
  }

  // Set free servers - only if no preference server exists
  // void setFreeServers(List<VpnServer> servers) {
  //   _freeServers = servers;
  //
  //   if (servers.isEmpty) {
  //     if (!_hasPreferenceServer) {
  //       _selectedServer = null;
  //     }
  //     notifyListeners();
  //     return;
  //   }
  //
  //   // Only set/update server if no preference server exists
  //   if (!_hasPreferenceServer) {
  //     _selectedServer = servers.first;
  //     selectedIndex = 0;
  //     selectedTab = "free";
  //     _saveSelectedServer();
  //     debugPrint('Set default free server: ${_selectedServer!.country}');
  //   } else {
  //     // If preference server exists, try to find it in the new list to update index
  //     if (_selectedServer != null && selectedTab == "free") {
  //       for (int i = 0; i < servers.length; i++) {
  //         if (servers[i].id == _selectedServer!.id) {
  //           selectedIndex = i;
  //           _selectedServer = servers[i]; // Update with current object
  //           _saveSelectedServer();
  //           break;
  //         }
  //       }
  //     }
  //     debugPrint('Kept preference server: ${_selectedServer?.country}');
  //   }
  //   notifyListeners();
  // }

  void setFreeServers(List<VpnServer> servers) {
    _freeServers = servers;

    if (servers.isEmpty) {
      notifyListeners();
      return;
    }

    // Always try to find saved server in new list
    if (_hasPreferenceServer && _selectedServer != null) {
      bool found = false;
      for (int i = 0; i < servers.length; i++) {
        if (servers[i].id == _selectedServer!.id) {
          selectedIndex = i;
          _selectedServer = servers[i];
          found = true;
          break;
        }
      }

      if (!found) {
        _selectedServer = servers.first;
        selectedIndex = 0;
      }
      _saveSelectedServer();
    }
    else if (!_hasPreferenceServer) {
      _selectedServer = servers.first;
      selectedIndex = 0;
      selectedTab = "free";
      _saveSelectedServer();
    }

    notifyListeners();
  }

  // Set pro servers - only if no preference server exists or if current is pro
  void setProServers(List<VpnServer> servers) {
    _proServers = servers;

    if (servers.isEmpty) {
      notifyListeners();
      return;
    }

    // Only update if preference server exists and is in pro tab
    if (_hasPreferenceServer && _selectedServer != null && selectedTab == "pro") {
      for (int i = 0; i < servers.length; i++) {
        if (servers[i].id == _selectedServer!.id) {
          selectedIndex = i;
          _selectedServer = servers[i]; // Update with current object
          _saveSelectedServer();
          break;
        }
      }
    }
    notifyListeners();
  }

  // Clear selected server data and reset to free servers
  Future<void> clearSelectedServer() async {
    try {
      await Prefs.remove(_selectedServerKey);
      await Prefs.remove(_selectedIndexKey);
      await Prefs.remove(_selectedTabKey);

      _hasPreferenceServer = false;

      if (_freeServers.isNotEmpty) {
        _selectedServer = _freeServers.first;
        selectedIndex = 0;
        selectedTab = "free";
        _saveSelectedServer();
      } else {
        _selectedServer = null;
        selectedIndex = 0;
        selectedTab = "free";
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing selected server: $e');
    }
  }

  // Get selected server for VPN connection
  VpnServer? getSelectedServerForConnection() {
    // Return preference server if exists
    if (_hasPreferenceServer && _selectedServer != null) {
      return _selectedServer;
    }

    // Fallback to first free server if no preference server
    if (_freeServers.isNotEmpty) {
      return _freeServers.first;
    }

    return null;
  }

  // Check if a server is currently selected
  bool isServerSelected(VpnServer server, int index, String tab) {
    return index == selectedIndex &&
        tab == selectedTab &&
        _selectedServer != null &&
        _selectedServer!.id == server.id;
  }

  // Reset to default server (first free server)
  void resetToDefault() {
    if (_freeServers.isNotEmpty) {
      selectedIndex = 0;
      selectedTab = "free";
      _selectedServer = _freeServers.first;
      _hasPreferenceServer = true;
      _saveSelectedServer();
      notifyListeners();
    }
  }

  // Force set free servers (ignores preference check)
  void forceSetFreeServers(List<VpnServer> servers) {
    _freeServers = servers;
    if (servers.isNotEmpty && _selectedServer == null) {
      _selectedServer = servers.first;
      selectedIndex = 0;
      selectedTab = "free";
      _saveSelectedServer();
    }
    notifyListeners();
  }

  // Check if should show servers based on preference
  bool shouldShowServers() {
    return _hasPreferenceServer || _freeServers.isNotEmpty;
  }

  // Get display servers based on preference
  List<VpnServer> getDisplayServers() {
    if (_hasPreferenceServer && _selectedServer != null) {
      return [_selectedServer!];
    }
    return _freeServers;
  }
}