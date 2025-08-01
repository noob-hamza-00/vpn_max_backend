import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vpnprowithjava/View/Widgets/recommended_server_screen.dart';
import '../../providers/servers_provider.dart';
import 'Widgets/servers_screen.dart';

class ServerTabs extends StatefulWidget {
  final bool isConnected;
   const ServerTabs({super.key, required this.isConnected});

  @override
  State<ServerTabs> createState() => _ServerTabsState();
}

class _ServerTabsState extends State<ServerTabs> {
  @override
  void initState() {
    super.initState();
    // Ensure provider is initialized when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ServersProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServersProvider>(
      builder: (context, value, child) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Select Country',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 13, 171, 24),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  text: 'ALL LOCATIONS',
                ),
                Tab(
                  text: 'RECOMMENDED',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ServersScreen(
                servers: value.freeServers,
                tab: "All Locations",
                isConnected: widget.isConnected,
              ),
              ServersScreenn(
                servers: value.freeServers,
                isConnected: widget.isConnected,
                tab: "Recommended",
              ),
            ],
          ),
        ),
      ),
    );
  }
}