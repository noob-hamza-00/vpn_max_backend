// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:onepref/onepref.dart';
// import 'package:vpnprowithjava/providers/ads_provider.dart';

// class ConsumableItems extends StatefulWidget {
//   const ConsumableItems({Key? key}) : super(key: key);
//   static const String routeName = "/ConsumableItems";

//   @override
//   State<ConsumableItems> createState() => _ConsumableItemsState();
// }

// class _ConsumableItemsState extends State<ConsumableItems> {
//   late final List<ProductDetails> _products = <ProductDetails>[];
//   late AdsProvider adsProvider;
//   IApEngine iApEngine = IApEngine();
//   int? selectedProduct = 0;
//   int reward = 0;
//   bool _isSubscribed = false;
//   List<ProductId> storeProductIds = <ProductId>[
//     ProductId(
//       id: "one_time_purchase",
//       isConsumable: true,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     adsProvider = AdsProvider();
//     getProducts();
//     adsProvider.loadAds();
//   }

//   void getProducts() async {
//     await iApEngine.getIsAvailable().then((value) async {
//       if (value) {
//         await iApEngine.queryProducts(storeProductIds).then((respose) => {
//               setState(() {
//                 _products.addAll(respose.productDetails);
//               })
//             });
//       }
//     });
//   }

//   Future<void> handlePurchase(ProductDetails product) async {
//     try {
//       if (!_isSubscribed) {
//         final PurchaseParam purchaseParam = PurchaseParam(
//           productDetails: product,
//           applicationUserName: null,
//         );

//         final PurchaseDetails purchaseDetails =
//             (await InAppPurchase.instance.buyConsumable(
//           purchaseParam: purchaseParam,
//         )) as PurchaseDetails;

//         if (purchaseDetails.status == PurchaseStatus.purchased) {
//           setState(() {
//             _isSubscribed = true;
//           });
//           adsProvider.loadAds();
//         } else {}
//       }
//     } catch (e) {
//       print('Error during purchase: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: ListView.builder(
//         itemCount: _products.length,
//         itemBuilder: (context, index) => GestureDetector(
//           onTap: () async {
//             if (!_isSubscribed) {
//               await handlePurchase(_products[index]);
//               setState(() {
//                 _isSubscribed = true;
//               });
//               adsProvider.loadAds();
//             }
//           },
//           child: ListTile(
//             title: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Text(
//                 _products[index].title,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             subtitle: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Text(_products[index].price),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
