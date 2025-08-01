import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Added for notification permission
import 'package:vpnprowithjava/View/allowed_app_screen.dart';
import 'package:vpnprowithjava/View/server_screen.dart';
import 'package:vpnprowithjava/View/splash_screen.dart';
import 'package:workmanager/workmanager.dart';
import '../Repository/vpn_server_http.dart';
import '../Model/application_model.dart';
import '../providers/ads_provider.dart';
import '../providers/animation_provider.dart';
import '../providers/apps_provider.dart';
import '../providers/device_detail_provider.dart';
import '../providers/servers_provider.dart';
import '../providers/vpn_connection_provider.dart';
import '../utils/get_apps.dart';
import '../utils/environment.dart';

// Workmanager callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Handle background task here
    return Future.value(true);
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin , WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  var v5;
  var data;
  bool _isLoading = false;
  bool _isConnected = false;
  int _progressPercentage = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _scheduleDisconnectTask();
    }
  }

  void _scheduleDisconnectTask() {
    Workmanager().registerOneOffTask(
      "vpnDisconnectTask",
      "disconnectVpnTask",
      initialDelay: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWorkManager();
    // MobileAds.instance.initialize();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);


  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await Provider.of<AdsProvider>(context, listen: false).loadAds();
  //     await Provider.of<AdsProvider>(context, listen: false).loadInterstitialAd();
  //     // Request notification permission on init
  //     _requestPermission();
  //   });
  //   _getServers();
  //   _getAllApps();
  //   _loadAppState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await Provider.of<VpnConnectionProvider>(context, listen: false)
  //         .restoreVpnState();
  //   });
  // }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AdsProvider>(context, listen: false).loadAds();
      await Provider.of<AdsProvider>(context, listen: false).loadInterstitialAd();
      _requestPermission();

      // Initialize servers provider before getting servers
      await Provider.of<ServersProvider>(context, listen: false).initialize();

      _getServers();
      _getAllApps();
      _loadAppState();

      await Provider.of<VpnConnectionProvider>(context, listen: false)
          .restoreVpnState();
    });}

  void _initializeWorkManager() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  void _requestPermission ()async{
    // Request VPN permission on app start
    bool hasVpnPermission = await OpenVPN().requestPermissionAndroid();
    if (!hasVpnPermission) {
      Fluttertoast.showToast(
        msg: "VPN Permission not granted! Please grant permission to use VPN.",
        backgroundColor: Colors.red,
      );
    }
  }



  Future<void> _saveAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isConnected', _isConnected);
  }

  Future<void> _loadAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConnected = prefs.getBool('isConnected') ?? false;
    });
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
      _updateProgress();
    });
  }

  void _updateProgress() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_progressPercentage < 100) {
        setState(() {
          final provider =
          Provider.of<VpnConnectionProvider>(context, listen: false);
          if (provider.stage?.toString() == "VPNStage.connected") {
            _progressPercentage = 100;
            // Provider.of<AdsProvider>(context, listen: false)
            //     .showInterstitialAd();
          } else {
            _progressPercentage++;
          }
          _updateProgress();
        });
      } else {
        setState(() {
          _isLoading = false;
          _isConnected = true;
        });
        _saveAppState();
      }
    });
  }

  Future<void> _disconnect() async {
    setState(() {
      _isConnected = false;
      _progressPercentage = 0;
    });
    await _saveAppState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _saveAppState();
    Provider.of<AdsProvider>(context, listen: false).disposeAds();
  }

  _getAllApps() async {
    await Provider.of<AppsProvider>(context, listen: false).setDisallowList();
    List<ApplicationModel> appsList = [];
    Provider.of<AppsProvider>(context, listen: false).updateLoader(true);
    final apps = await GetApps.GetAllAppInfo();
    for (final app in apps) {
      appsList.add(
        ApplicationModel(isSelected: true, app: app),
      );
    }
    Provider.of<AppsProvider>(context, listen: false).setAllApps(appsList);
    Provider.of<AppsProvider>(context, listen: false).updateLoader(false);
    // Provider.of<AdsProvider>(context, listen: false).loadAds();
    // Provider.of<AdsProvider>(context, listen: false).loadInterstitialAd();
    Provider.of<DeviceDetailProvider>(context, listen: false).getDeviceInfo(v5);
  }

  _getServers() async {
    final myProvider = Provider.of<ServersProvider>(context, listen: false);

    // Initialize provider before checking servers
    if (!myProvider.isInitialized) {
      await myProvider.initialize();
    }

    if (myProvider.freeServers.isEmpty || myProvider.proServers.isEmpty) {
      final free = await VpnServerHttp(context).getServers("free");
      myProvider.setFreeServers(free);
      final pro = await VpnServerHttp(context).getServers("premium");
      myProvider.setProServers(pro);
    }
  }

  Widget _buildSpeedBox(String title, String value, String unit) {
    return Container(
      height: 120,
      width: 160,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.poppins(
              color: const Color(0xFF0DAB18),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final textScale = MediaQuery.textScaleFactorOf(context);
          final isLargeScreen = MediaQuery.sizeOf(context).shortestSide > 600;

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0E1DA3),
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/nointernetimage.png",
                    height: isLargeScreen ? 150 : 120,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please check your internet connection',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: textScale * (isLargeScreen ? 16 : 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E1DA3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  SplashScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      child: Text(
                        'Refresh',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: textScale * 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // Your new connection method
  Future<void> _connectVPN(
      BuildContext context,
      VpnConnectionProvider vpnValue,
      ServersProvider serversProvider,
      ) async {
    final selectedServer = serversProvider.selectedServer;

    if (selectedServer == null) {
      Fluttertoast.showToast(
        msg: "Please select a server first",
        backgroundColor: Colors.red,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServerTabs(isConnected: vpnValue.isConnected),
        ),
      );
      return;
    }

    // Check permissions
    bool hasVpnPermission = await OpenVPN().requestPermissionAndroid();
    if (!hasVpnPermission) {
      Fluttertoast.showToast(
        msg: "VPN Permission not granted!",
        backgroundColor: Colors.red,
      );
      return;
    }

    bool hasNotificationPermission = await _requestNotificationPermission();
    if (!hasNotificationPermission) {
      Fluttertoast.showToast(
        msg: "Notification permission not granted!",
        backgroundColor: Colors.orange,
      );
    }

    final adsProvider = Provider.of<AdsProvider>(context, listen: false);
    await adsProvider.loadInterstitialAd();
    adsProvider.showInterstitialAd();

    final apps = Provider.of<AppsProvider>(context, listen: false);

    if (vpnValue.getInitCheck()) vpnValue.initialize();

    vpnValue.setRadius();
    _startLoading();

    try {
      await vpnValue.initPlatformState(
        selectedServer.ovpn,
        selectedServer.country,
        apps.getDisallowedList,
        selectedServer.username ?? "",
        selectedServer.password ?? "",
      );
      await Future.delayed(const Duration(seconds: 3));
      Fluttertoast.showToast(
        msg: "VPN Connected Successfully",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to connect to VPN: $e",
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }


  // Method to request notification permission
  Future<bool> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        // Fluttertoast.showToast(
        //   msg: "Notification permission granted!",
        //   backgroundColor: Colors.green,
        // );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "Notification permission denied! VPN notifications may not appear.",
          backgroundColor: Colors.red,
        );
        return false;
      }
    }
    return true; // Permission already granted
  }

  double bytesPerSecondToMbps(double bytesPerSecond) {
    const bitsInByte = 8;
    const bitsInMegabit = 1000000;
    return (bytesPerSecond * bitsInByte) / bitsInMegabit;
  }

  @override
  Widget build(BuildContext context) {
    double safeAreaHeightTop = MediaQuery.of(context).viewInsets.top;
    EdgeInsets safeArea = MediaQuery.of(context).padding;
    double topPadding = safeArea.top;
    double screenHeight1 = MediaQuery.of(context).size.height;
    double safeAreaHeightBottom = MediaQuery.of(context).viewInsets.bottom;
    double appBarHeight = AppBar().preferredSize.height;
    double usableScreenHeight = screenHeight1 -
        safeAreaHeightTop -
        safeAreaHeightBottom -
        appBarHeight -
        topPadding;

    var statusHeight = MediaQuery.of(context).viewPadding.top;
    var screenHeight = usableScreenHeight;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenSize =
        MediaQuery.of(context).size.height * MediaQuery.of(context).size.width;
    print('height: $screenHeight ');
    print('width : $screenWidth');
    print('total size $screenSize');

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: statusHeight, left: screenWidth * 0.025),
                  child: Container(
                    color: Colors.black,
                    height: screenHeight * 0.08,
                    width: screenWidth * 0.57,
                    child: Row(
                      children: [
                        Text(' VPN',
                            style: GoogleFonts.poppins(
                                fontSize: screenSize >= 370000
                                    ? screenSize * 0.00011
                                    : screenSize * 0.00013,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0)),
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Text(
                            'Max',
                            style: GoogleFonts.poppins(
                                fontSize: screenSize >= 370000
                                    ? screenSize * 0.00011
                                    : screenSize * 0.00013,
                                color: const Color.fromARGB(255, 13, 171, 24),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: statusHeight, right: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AllowedAppsScreen()));
                    },
                    child: Container(
                      height: screenHeight * 0.055,
                      width: screenWidth * 0.35,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text(
                            'APP FILTER',
                            style: GoogleFonts.poppins(
                                fontSize: screenSize >= 370000
                                    ? screenSize * 0.000039
                                    : screenSize * 0.000045,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.030),
                  child: Container(
                    height: 95,
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Consumer<VpnConnectionProvider>(
                            builder: (context, value, child) => Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'UPLOAD',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      value.stage?.toString() ==
                                          "VPNStage.connected"
                                          ? bytesPerSecondToMbps(
                                          double.parse(
                                              value.status!.byteOut ??
                                                  "0000"))
                                          .toStringAsFixed(2)
                                          : "00:00",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'mbps',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0DAB18),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                const SizedBox(width: 10,),
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.030),
                  child: Container(
                    height: 95,
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Consumer<VpnConnectionProvider>(
                            builder: (context, value, child) => Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'DOWNLOAD',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      value.stage?.toString() ==
                                          "VPNStage.connected"
                                          ? bytesPerSecondToMbps(
                                          double.parse(value
                                              .status!.byteIn ??
                                              "0000"))
                                          .toStringAsFixed(2)
                                          : "00:00",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'mbps',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0DAB18),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            // Update ad widget in build method
            Consumer<AdsProvider>(
              builder: (context, value, child) {
                final bannerAd = value.getBannerAd();
                if (bannerAd != null) {
                  return Container(
                    alignment: Alignment.center,
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  );
                } else {
                  return const SizedBox(
                    height: 50,
                  );
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.07),
              child: Consumer<VpnConnectionProvider>(
                builder: (context, value, child) => SizedBox(
                  width: screenWidth * 0.77,
                  height: screenWidth * 0.77,
                  child: value.stage?.toString() == "VPNStage.connected"
                      ? Image.asset(
                    "assets/images/connectedgiffy.gif",
                    fit: BoxFit.contain,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame == null) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                              child: CircularProgressIndicator()),
                        );
                      }
                      return child;
                    },
                  )
                      : Image.asset(
                    "assets/images/firstimagegiffy.gif",
                    fit: BoxFit.contain,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame == null) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                              child: CircularProgressIndicator()),
                        );
                      }
                      return child;
                    },
                  ),
                ),
              ),
            ),
    Consumer2<VpnConnectionProvider, ServersProvider>(
    builder: (context, vpnValue, serversProvider, child) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) =>  ServerTabs(isConnected: vpnValue.isConnected,)
                      ));
                    },
                    child: Container(
                      height: screenHeight * 0.075,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer<ServersProvider>(
                            builder: (context, provider, child) {
                              if (provider.selectedServer == null) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                                  child: Icon(Icons.flag, size: 30, color: Colors.white),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: Container(
                                  height: 38,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/flags/${provider.selectedServer!.countryCode.toLowerCase()}.png'),
                                      )),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Consumer<ServersProvider>(
                              builder: (context, provider, child) {
                                return Text(
                                  provider.selectedServer == null
                                      ? "Select your country"
                                      : provider.selectedServer!.country,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: screenSize * 0.00006,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),

            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.011,
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Consumer<CountProvider>(
                builder: (context, value1, child) {
                  return Container(
                      height: screenHeight * 0.075,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        color: value1.isconnect
                            ? const Color.fromARGB(255, 14, 29, 163)
                            : const Color.fromARGB(255, 13, 171, 24),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _isLoading
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 13, 171, 24),
                            ),
                            Container(
                              color: const Color.fromARGB(255, 14, 29, 163),
                              width: (_progressPercentage / 100) * screenWidth * 0.95,
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: (_progressPercentage / 100) * screenWidth * 0.95,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                            Positioned(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 40.0,
                                  top: screenHeight * 0.01,
                                ),
                                child: Center(
                                  child: Text(
                                    'CONNECTING...($_progressPercentage%) ',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : !_isConnected
                          ? Consumer2<VpnConnectionProvider, ServersProvider>(
                          builder: (context, vpnValue, serversProvider, child) {

                             return ElevatedButton(
                                  onPressed: () async {
                                    // Check if VPN is already connected
                                    String comp = vpnValue.stage?.toString() == null
                                        ? "Disconnect"
                                        : vpnValue.stage.toString().split('.').last;
                                    if (comp == "connected") {
                                      // Show disconnect dialog before disconnecting
                                      showDisconnectDialog(context, () async {
                                        vpnValue.engine.disconnect();
                                        vpnValue.resetRadius();
                                        await _disconnect();
                                        Fluttertoast.showToast(
                                          msg: "VPN Disconnected Successfully",
                                          backgroundColor: Colors.red,
                                        );
                                      });
                                      return;
                                    }

                                    // Check VPN permission
                                    bool hasVpnPermission =
                                    await OpenVPN().requestPermissionAndroid();
                                    if (!hasVpnPermission) {
                                      Fluttertoast.showToast(
                                        msg: "VPN Permission not granted!",
                                        backgroundColor: Colors.red,
                                      );
                                      return;
                                    }

                                    // Check notification permission
                                    bool hasNotificationPermission =
                                    await _requestNotificationPermission();
                                    if (!hasNotificationPermission) {
                                      Fluttertoast.showToast(
                                        msg: "Notification permission not granted!",
                                        backgroundColor: Colors.orange,
                                      );
                                    }

                                    // Get selected server
                                    final selectedServer = serversProvider.selectedServer;
                                    if (selectedServer == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select a server first",
                                        backgroundColor: Colors.red,
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>  ServerTabs( isConnected: vpnValue.isConnected,),
                                        ),
                                      );
                                      return;
                                    }

                                    // Proceed with connection
                                    vpnValue.setRadius();
                                    final adsProvider =
                                    Provider.of<AdsProvider>(context, listen: false);
                                    await adsProvider.loadInterstitialAd();
                                    adsProvider.showInterstitialAd();

                                    final apps =
                                    Provider.of<AppsProvider>(context, listen: false);

                                    if (vpnValue.getInitCheck()) {
                                      vpnValue.initialize();
                                    }

                                    _startLoading();
                                    try {
                                      await vpnValue.initPlatformState(
                                        selectedServer.ovpn,
                                        selectedServer.country,
                                        apps.getDisallowedList,
                                        selectedServer.username ?? "",
                                        selectedServer.password ?? "",
                                      );
                                      await Future.delayed(const Duration(seconds: 3));
                                      Fluttertoast.showToast(
                                        msg: "VPN Connected Successfully",
                                        backgroundColor: Colors.green,
                                      );
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                        msg: "Failed to connect to VPN: $e",
                                        backgroundColor: Colors.red,
                                      );
                                      setState(() {
                                        _isLoading = false;
                                        _isConnected = false;
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      )),
                                      backgroundColor: const MaterialStatePropertyAll(
                                        Color.fromARGB(255, 13, 171, 24),
                                      )),
                                      child: Text(
                                        'CONNECT',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: screenSize * 0.000048,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    );
                                  })
                                      : Consumer2<VpnConnectionProvider, ServersProvider>(
    builder: (context, vpnValue, serversProvider, child)  {
      return ElevatedButton(
                          onPressed: () async {
                            if (vpnValue.stage?.toString() == "VPNStage.connected") {
                              // If connected, disconnect
                              showDisconnectDialog(context, () async {
                                await _disconnect();
                                vpnValue.engine.disconnect();
                                vpnValue.resetRadius();
                                Fluttertoast.showToast(
                                  msg: "VPN Disconnected Successfully",
                                  backgroundColor: Colors.red,
                                );
                              });
                            } else {
                              // If not connected, connect
                              await _connectVPN(context, vpnValue, serversProvider);
                            }
                  },
                  style: ButtonStyle(
                  shape: MaterialStateProperty.all<
                  RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  ),
                  ),
                  backgroundColor: MaterialStatePropertyAll(
                  vpnValue.stage?.toString() == "VPNStage.connected"
                  ? const Color.fromARGB(255, 14, 29, 163)
                      : const Color.fromARGB(255, 13, 171, 24),
                  )),
                  child: Text(
                  vpnValue.stage?.toString() == "VPNStage.connected"
                  ? 'DISCONNECT'
                      : 'CONNECT',
                  style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: screenSize * 0.000048,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  ),
                  ),
                  );
                  }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}