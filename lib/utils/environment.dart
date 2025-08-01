import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//if you got problems with your endpoint, read FAQ in the docs
const String endpoint = "https://vpn.technosofts.net";
// "http://vpn-project.technosofts.net"; //<= Replace with yours

const String appname = "VPN MAX";

const String defaultVpnUsername = "";

/// key be change kry
const String defaultVpnPassword = "";

// const bool showAds = true;
const bool groupCountries = false;
const bool showAllCountries = true;

//IOS AppstoreID
//Do not change this without read the instructions
const String vpnExtensionIdentifier = "com.nerdtech.vpn.VPNExtensions";
const String groupIdentifier = "group.com.nerdtech.vpn";
const String appstoreId = "";

const String androidAdmobAppId = "ca-app-pub-5697489208417002~8898868198";
const String iosAdmobAppId = "YOUR_ADMOB_ID_HERE";

const String banner1Android =
    "ca-app-pub-2213641325340669/1752979767"; //HEAD_BANNER
const String inters1Android =
    "ca-app-pub-2213641325340669/1563533223"; //CONNECT_VPN
// const String inters2Android =
//     "ca-app-pub-4826348586303925/8111685813"; //DISCONNECT_VPN
// const String inters3Android =
//     "ca-app-pub-4826348586303925/6462674176"; //SELECT_SERVER

const String banner1IOS = "none"; //BOTTOM_BANNER
const String inters1IOS =
    "ca-app-pub-3940256099942544/1033173712"; //CONNECT_VPN
// const String inters2IOS =
//     "ca-app-pub-3940256099942544/1033173712"; //DISCONNECT_VPN
// const String inters3IOS =
//     "ca-app-pub-3940256099942544/1033173712"; //SELECT_SERVER

//Do not touch section ===================================================================
const String api = "$endpoint/api/";
// const String api = "http://192.168.10.71:8000/api/";

String get banner1 => Platform.isIOS ? banner1IOS : banner1Android;
// String get banner2 => Platform.isIOS ? banner2IOS : banner2Android;
String get inters1 => Platform.isIOS ? inters1IOS : inters1Android;
// String get inters2 => Platform.isIOS ? inters2IOS : inters2Android;
// String get inters3 => Platform.isIOS ? inters3IOS : inters3Android;

void showDisconnectDialog(BuildContext context, VoidCallback onDisconnect) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Disconnect VPN',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to disconnect from VPN?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDisconnect();
            },
            child: Text(
              'Disconnect',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Add this method to your class
void showPremiumDialog(BuildContext context, VoidCallback onDisconnect) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  '🌟 Upgrade to Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Subtitle
                Text(
                  'Unlock unlimited features and enjoy the best VPN experience!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Premium features
                Column(
                  children: [
                    buildPremiumFeature('🚀', 'Unlimited High-Speed Servers'),
                    buildPremiumFeature('🛡️', 'Advanced Security Protocols'),
                    buildPremiumFeature('📱', 'Ad-Free Experience'),
                    buildPremiumFeature('🌍', 'Global Server Locations'),
                    buildPremiumFeature('⚡', 'Priority Connection Speed'),
                  ],
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDisconnect();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Disconnect',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to premium purchase page
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => PremiumPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Get Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Helper method for premium features
Widget buildPremiumFeature(String icon, String feature) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            feature,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      ],
    ),
  );
}
