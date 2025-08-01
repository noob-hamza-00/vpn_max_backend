import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/vpn_config.dart';
import '../../Model/vpn_server.dart';
import '../../providers/servers_provider.dart';
import '../../providers/vpn_provider.dart';
import '../../providers/vpn_connection_provider.dart';
import 'navbar.dart';


class ServersScreen extends StatefulWidget {
  final String tab;
  final List<VpnServer> servers;
  final bool isConnected;

  const ServersScreen({
    super.key,
    required this.servers,
    required this.isConnected,
    required this.tab,
  });

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {

  // void _changeServerLocation(BuildContext context, VpnServer server) {
  //   final controller = Provider.of<ServersProvider>(context, listen: false);
  //   final controllerVPN = Provider.of<VpnProvider>(context, listen: false);
  //
  //   controller.setSelectedIndex(widget.servers.indexOf(server));
  //   controller.setSelectedTab(widget.tab);
  //   controller.setSelectedServer(server);
  //   controllerVPN.vpnConfig = VpnConfig.fromJson(server.toJson());
  //   Navigator.pop(context);
  // }

  void _changeServerLocation(BuildContext context, VpnServer server) async {
    final controller = Provider.of<ServersProvider>(context, listen: false);
    final vpnProvider = Provider.of<VpnConnectionProvider>(context, listen: false);
    final vpnConfigProvider = Provider.of<VpnProvider>(context, listen: false);

    final isConnected = vpnProvider.stage?.toString() == "VPNStage.connected";

    if (isConnected) {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey.shade900,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text('Switch Server?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You are currently connected to VPN.',
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('Changing server will temporarily disconnect your connection.',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white, letterSpacing: 1)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('SWITCH',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Create a Completer to track when we should close the dialog
      final dialogCompleter = Completer<void>();
      final minimumWait = Future.delayed(const Duration(seconds: 3));

      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent back button from closing
            child: AlertDialog(
              backgroundColor: Colors.grey.shade900.withOpacity(0.9),
              content: FutureBuilder(
                future: Future.wait([dialogCompleter.future, minimumWait]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // When future completes, show success briefly then auto-close
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  const BottomNavigator(),), (route) => false,);
                      }
                    });

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 40),
                        const SizedBox(height: 20),
                        Text('Connected to ${server.country}!',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    );
                  }

                  // Show loading while processing
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.amber),
                      const SizedBox(height: 20),
                      Text('Switching to ${server.country}...',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

      try {
        // Update server configuration
        controller.setSelectedIndex(widget.servers.indexOf(server));
        controller.setSelectedTab(widget.tab);
        controller.setSelectedServer(server);
        vpnConfigProvider.vpnConfig = VpnConfig.fromJson(server.toJson());

        // Start disconnection process
        vpnProvider.startServerChange();
         vpnProvider.engine.disconnect();
        await Future.delayed(const Duration(seconds: 1));

        // Connect to new server
        await vpnProvider.initPlatformState(
          server.ovpn,
          server.country,
          [],
          server.username ?? "",
          server.password ?? "",
        );

        // Complete the future to trigger dialog update
        dialogCompleter.complete();
      } catch (e) {
        // Close dialog immediately on error
        if (mounted) Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.red,
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Connection failed: ${e.toString()}',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        vpnProvider.completeServerChange();
      }
    } else {
      // If not connected, just update the server
      controller.setSelectedIndex(widget.servers.indexOf(server));
      controller.setSelectedTab(widget.tab);
      controller.setSelectedServer(server);
      vpnConfigProvider.vpnConfig = VpnConfig.fromJson(server.toJson());

      if (mounted) Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<ServersProvider, VpnProvider>(
      builder: (context, controller, controllerVPN, child) {
        if (widget.servers.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text("No Servers Found", style: TextStyle(color: Colors.white, fontSize: 20)),
                  SizedBox(height: 8),
                  Text("Please check your internet connection\nand try again",
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // Header with server count
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text('${widget.servers.length} servers available',
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),

              // Servers list
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemCount: widget.servers.length,
                    itemBuilder: (context, index) {
                      final server = widget.servers[index];
                      final isSelected = controller.isServerSelected(server, index, widget.tab);

                      return InkWell(
                        onTap: () => _changeServerLocation(context, server),
                        // onTap: () {
                        //
                        //     // showDialog<bool>(
                        //     //   context: context,
                        //     //   builder: (context) => AlertDialog(
                        //     //     title: const Text('Change VPN Location?', style: TextStyle(color: Colors.white)),
                        //     //     content: const Text(
                        //     //       'Are you sure you want to change your VPN location?',
                        //     //       style: TextStyle(color: Colors.white),
                        //     //     ),
                        //     //     backgroundColor: Colors.grey.shade900,
                        //     //     actions: [
                        //     //       TextButton(
                        //     //         onPressed: () => Navigator.pop(context, false),
                        //     //         child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        //     //       ),
                        //     //       TextButton(
                        //     //         onPressed: () => Navigator.pop(context, true),
                        //     //         child: const Text('OK', style: TextStyle(color: Colors.amber)),
                        //     //       ),
                        //     //     ],
                        //     //   ),
                        //     // ).then((confirmed) {
                        //     //   if (confirmed == true) {
                        //     //     _changeServerLocation(context, server);
                        //     //   }
                        //     // });
                        //
                        //     // _changeServerLocation(context, server);
                        //
                        // },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.grey.shade800 : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade600, width: 2),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/flags/${server.countryCode.toLowerCase()}.png'),
                                ),
                              ),
                            ),
                            title: Text(server.country,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (server.country.isNotEmpty)
                                  Text(server.country, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 4),
                                const Row(
                                  children: [
                                    Icon(Icons.signal_cellular_alt, size: 16, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text('Online', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 28,
                                color: isSelected ? Colors.amber : Colors.grey),
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