import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/ads_provider.dart';
import '../utils/preferences.dart';

// Dummy ProductDetails class for testing when IAP is not available
class DummyProductDetails extends ProductDetails {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String price;
  @override
  final double rawPrice;
  @override
  final String currencyCode;

  DummyProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  }) : super(
    id: id,
    title: title,
    description: description,
    price: price,
    rawPrice: rawPrice,
    currencyCode: currencyCode,
  );
}

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool hasActiveSubscription = false;
  String? _uuid;
  ProductDetails? _oneTimePurchaseProduct;

  // Create dummy products for testing when in-app purchase is not available
  List<ProductDetails> _createDummyProducts() {
    return [
      // This is a mock ProductDetails - in a real app you wouldn't do this
      // but for testing purposes when IAP is not available, we create dummy products
      DummyProductDetails(
        id: 'vpnmax_999_1m',
        title: 'VPN Max Monthly',
        description: 'Monthly VPN subscription',
        price: '\$9.99',
        rawPrice: 9.99,
        currencyCode: 'USD',
      ),
      DummyProductDetails(
        id: 'vpnmax_99_1year',
        title: 'VPN Max Yearly',
        description: 'Yearly VPN subscription',
        price: '\$99.99',
        rawPrice: 99.99,
        currencyCode: 'USD',
      ),
      DummyProductDetails(
        id: 'one_time_purchase',
        title: 'VPN Max Lifetime',
        description: 'One-time VPN purchase',
        price: '\$299.99',
        rawPrice: 299.99,
        currencyCode: 'USD',
      ),
    ];
  }

  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    print('In-app purchase available: $available');
    if (!available) {
      print('In-app purchase not available, creating dummy products for testing');
      // Create dummy products for testing when in-app purchase is not available
      setState(() {
        _products = _createDummyProducts();
        
        // Find one-time purchase product in dummy products
        try {
          _oneTimePurchaseProduct = _products.firstWhere(
            (product) => product.id == 'one_time_purchase',
          );
          print('Dummy one-time purchase product found: ${_oneTimePurchaseProduct?.id}');
        } catch (e) {
          print('One-time purchase product not found in dummy products');
          _oneTimePurchaseProduct = null;
        }
      });
      return;
    }

    // Check subscription status from preferences
    hasActiveSubscription = Prefs.getBool('isSubscribed') ?? false;

    final Set<String> ids = {
      'vpnmax_999_1m',
      'vpnmax_99_1year',
      'one_time_purchase',
    };

    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
    print('Product query response: ${response.productDetails.length} products found');
    print('Product query error: ${response.error}');
    
    if (response.error != null) {
      print('Error loading products, creating dummy products for testing');
      setState(() {
        _products = _createDummyProducts();
        
        // Find one-time purchase product in dummy products
        try {
          _oneTimePurchaseProduct = _products.firstWhere(
            (product) => product.id == 'one_time_purchase',
          );
          print('Dummy one-time purchase product found: ${_oneTimePurchaseProduct?.id}');
        } catch (e) {
          print('One-time purchase product not found in dummy products');
          _oneTimePurchaseProduct = null;
        }
      });
      return;
    }
    setState(() {
      _products = response.productDetails;
      print('Loaded products: ${_products.map((p) => p.id).toList()}');
      
      // Find one-time purchase product safely
      try {
        _oneTimePurchaseProduct = _products.firstWhere(
          (product) => product.id == 'one_time_purchase',
        );
        print('One-time purchase product found: ${_oneTimePurchaseProduct?.id}');
      } catch (e) {
        print('One-time purchase product not found in products list');
        _oneTimePurchaseProduct = null;
      }
    });

    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          Prefs.setBool('isSubscribed', true);
          Provider.of<AdsProvider>(context, listen: false).setSubscriptionStatus();
          setState(() {
            hasActiveSubscription = true;
          });
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          _showErrorDialog('Purchase failed. Please try again.');
        }
      }
    });
  }

  void _buySubscription(ProductDetails product) {
    if (hasActiveSubscription) {
      _showAlreadySubscribedDialog();
      return;
    }

    // Check if this is a dummy product (for testing)
    if (product is DummyProductDetails) {
      _showDummyPurchaseDialog(product);
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    // For subscriptions, use buyNonConsumable (this is correct for Android)
    // Google Play handles subscription renewals automatically
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Add this method to your _MoreScreenState class
  Future<void> _launchEmailFeedback() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'vpnapp@technosofts.net', // Replace with your support email
      query: 'subject=VPN Max Feedback&body=Dear VPN Max Team,\n\n', // Pre-filled email content
    );

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      _showErrorDialog('Could not launch email client. Please send your feedback to support@technosofts.com');
    }
  }

  void _buyOneTimePurchaseProduct() {
    if (hasActiveSubscription) {
      _showAlreadySubscribedDialog();
      return;
    }

    if (_oneTimePurchaseProduct != null) {
      // Check if this is a dummy product (for testing)
      if (_oneTimePurchaseProduct is DummyProductDetails) {
        _showDummyPurchaseDialog(_oneTimePurchaseProduct!);
        return;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: _oneTimePurchaseProduct!);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  void _showAlreadySubscribedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Already Premium',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'You already have an active premium subscription. Enjoy all the premium features!',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDummyPurchaseDialog(ProductDetails product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Test Mode',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is a test/debug version. In the real app, this would open Google Play payment for:',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Price: ${product.price}',
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Product ID: ${product.id}',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To test real purchases, you need to:\n• Upload the app to Google Play Console\n• Configure in-app products\n• Use a signed release APK',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
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

  Future<void> _loadUuid() async {
    String? storedUuid = Prefs.getString('uuid');
    if (storedUuid == null) {
      final uuid = Uuid().v4();
      await Prefs.setString('uuid', uuid);
      setState(() {
        _uuid = uuid;
      });
    } else {
      setState(() {
        _uuid = storedUuid;
      });
    }
  }

  void _showSubscriptionDialog(BuildContext context) {
    if (hasActiveSubscription) {
      _showAlreadySubscribedDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiumAccessScreen(
          products: _products,
          oneTimePurchaseProduct: _oneTimePurchaseProduct,
          onSubscribe: _buySubscription,
          onOneTimePurchase: _buyOneTimePurchaseProduct,
          hasActiveSubscription: hasActiveSubscription,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadUuid();
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenSize = MediaQuery.of(context).size.height * MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: statusHeight + 10, left: screenSize * 0.00005),
              child: Container(
                height: screenHeight * 0.085,
                width: screenWidth * 0.91,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: ListTile(
                    leading: Icon(
                      hasActiveSubscription ? Icons.check_circle : Icons.electric_bolt,
                      color: hasActiveSubscription ? Colors.green : Colors.amber,
                      size: screenSize * 0.00008,
                    ),
                    title: Text(
                      hasActiveSubscription ? 'Premium Active' : 'Get Access Premium Service',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        _showSubscriptionDialog(context);
                      },
                      child: Container(
                        height: screenSize >= 370000 ? screenHeight * 0.037 : screenHeight * 0.04,
                        width: screenSize >= 370000 ? screenWidth * 0.19 : screenWidth * 0.20,
                        decoration: BoxDecoration(
                          color: hasActiveSubscription ? Colors.grey[700] : const Color.fromARGB(255, 13, 171, 24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            hasActiveSubscription ? 'ACTIVE' : 'UNLOCK',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: screenSize >= 370000 ? screenSize * 0.000034 : screenSize * 0.000038,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenSize * 0.00003, left: screenSize * 0.00005),
              child: InkWell(
                onTap: () {
                  Share.share('https://play.google.com/store/apps/details?id=com.technosofts.vpnmax');
                },
                child: Container(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.91,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: screenSize * 0.00009,
                      ),
                      title: Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenSize >= 370000 ? screenSize * 0.000056 : screenSize * 0.000060,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenSize * 0.00003, left: screenSize * 0.00005),
              child: InkWell(
                onTap: () {
                  StoreRedirect.redirect(androidAppId: 'com.technosofts.vpnmax');
                },
                child: Container(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.91,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: screenSize * 0.00009,
                      ),
                      title: Text(
                        'Rate this app',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenSize >= 370000 ? screenSize * 0.000056 : screenSize * 0.000060,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(top: screenSize * 0.00003, left: screenSize * 0.00005),
            //   child: InkWell(
            //     onTap: () {
            //       StoreRedirect.redirect(androidAppId: 'com.technosofts.vpnmax');
            //     },
            //     child: Container(
            //       height: screenHeight * 0.07,
            //       width: screenWidth * 0.91,
            //       decoration: BoxDecoration(
            //         color: Colors.grey[900],
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: Center(
            //         child: ListTile(
            //           leading: Icon(
            //             Icons.feedback,
            //             color: Colors.white,
            //             size: screenSize * 0.00009,
            //           ),
            //           title: Text(
            //             'Feedback',
            //             style: GoogleFonts.poppins(
            //               color: Colors.white,
            //               fontSize: screenSize >= 370000 ? screenSize * 0.000056 : screenSize * 0.000060,
            //               fontWeight: FontWeight.w800,
            //             ),
            //           ),
            //           trailing: const Icon(
            //             Icons.arrow_forward_ios_outlined,
            //             size: 15,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: screenSize * 0.00003, left: screenSize * 0.00005),
              child: InkWell(
                onTap: _launchEmailFeedback,
                child: Container(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.91,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.feedback,
                        color: Colors.white,
                        size: screenSize * 0.00009,
                      ),
                      title: Text(
                        'Feedback',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenSize >= 370000 ? screenSize * 0.000056 : screenSize * 0.000060,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // subtitle: Text(
                      //   'Send us your feedback',
                      //   style: GoogleFonts.poppins(
                      //     color: Colors.white70,
                      //     fontSize: screenSize * 0.00003,
                      //   ),
                      // ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenSize * 0.00003, left: screenSize * 0.00005),
              child: Container(
                height: screenHeight * 0.1,
                width: screenWidth * 0.91,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: ListTile(
                    title: Text(
                      'UUID',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenSize >= 370000 ? screenSize * 0.000056 : screenSize * 0.000060,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      _uuid ?? 'Loading UUID...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: screenSize * 0.00003,
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: screenSize >= 370000 ? screenHeight * 0.038 : screenHeight * 0.04,
                        width: screenSize >= 370000 ? screenWidth * 0.15 : screenWidth * 0.16,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 13, 171, 24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              if (_uuid != null) {
                                Clipboard.setData(ClipboardData(text: _uuid!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              }
                            },
                            child: Text(
                              'COPY',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: screenSize >= 370000 ? screenSize * 0.000034 : screenSize * 0.000038,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumAccessScreen extends StatelessWidget {
  final List<ProductDetails> products;
  final ProductDetails? oneTimePurchaseProduct;
  final Function(ProductDetails) onSubscribe;
  final Function() onOneTimePurchase;
  final bool hasActiveSubscription;

  const PremiumAccessScreen({
    super.key,
    required this.products,
    required this.oneTimePurchaseProduct,
    required this.onSubscribe,
    required this.onOneTimePurchase,
    required this.hasActiveSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: size.height * 0.25,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      hasActiveSubscription ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hasActiveSubscription ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          hasActiveSubscription ? Icons.check_circle : Icons.electric_bolt,
                          color: hasActiveSubscription ? Colors.green : Colors.amber,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasActiveSubscription ? 'Premium Already Active' : 'Unlock Premium Features',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          hasActiveSubscription
                              ? 'You already have access to all premium VPN services and features'
                              : 'Get unlimited access to all premium VPN services and features',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (hasActiveSubscription) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Premium Active!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re all set! Enjoy unlimited access to all premium features.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  _buildSectionHeader('Choose Your Plan'),
                  const SizedBox(height: 12),
                  ..._buildSubscriptionCards(),
                  if (oneTimePurchaseProduct != null) ...[
                    _buildOneTimePurchaseCard(),
                    const SizedBox(height: 15),
                  ],
                ],
                _buildFooterInformation(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget> _buildSubscriptionCards() {
    return products.where((product) => product.id != 'one_time_purchase').map((product) {
      bool isYearly = product.id.contains('1year');

      return Opacity(
        opacity: hasActiveSubscription ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[900]!, Colors.blue[800]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: hasActiveSubscription ? null : () => onSubscribe(product),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isYearly && !hasActiveSubscription) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MOST POPULAR',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title.replaceAll("- World's Fast ", '').replaceAll("Servers", '').trim(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isYearly ? 'Billed annually' : 'Billed monthly',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              product.price,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isYearly ? 'per year' : 'per month',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: hasActiveSubscription ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          hasActiveSubscription ? 'Already Subscribed' : 'Buy Now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildOneTimePurchaseCard() {
    return Opacity(
      opacity: hasActiveSubscription ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[900]!, Colors.green[800]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: hasActiveSubscription ? null : onOneTimePurchase,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ONE-TIME PURCHASE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lifetime Access',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pay once, use forever',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        oneTimePurchaseProduct!.price,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: hasActiveSubscription ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        hasActiveSubscription ? 'Already Subscribed' : 'BUY NOW',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInformation() {
    return Column(
      children: [
        Text(
          'Subscriptions will auto-renew until cancelled. You can manage your subscriptions in your account settings.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}