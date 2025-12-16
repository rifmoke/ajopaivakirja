import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io' show Platform;

class SubscriptionProvider with ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  
  bool _isPremium = false;
  DateTime? _subscriptionEndDate;
  
  // Product IDs (configured in Google Play Console)
  static const String monthlySubscriptionId = 'premium_monthly';
  static const String yearlySubscriptionId = 'premium_yearly';
  
  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;

  SubscriptionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // In-app purchases only work on Android and iOS
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // On desktop/web, grant premium for testing
      _isPremium = true;
      _subscriptionEndDate = DateTime.now().add(const Duration(days: 365));
      notifyListeners();
      return;
    }
    
    // Check if in-app purchase is available
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );
      
      // Load products
      await _loadProducts();
      
      // Load saved subscription status
      await _loadSubscriptionStatus();
      
      // Restore purchases
      await _restorePurchases();
    }
    
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({
      monthlySubscriptionId,
      yearlySubscriptionId,
    });
    
    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }
    
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    
    final endDateMs = prefs.getInt('subscription_end_date');
    if (endDateMs != null) {
      _subscriptionEndDate = DateTime.fromMillisecondsSinceEpoch(endDateMs);
      
      // Check if subscription has expired
      if (_subscriptionEndDate!.isBefore(DateTime.now())) {
        _isPremium = false;
        await _saveSubscriptionStatus(false, null);
      }
    }
    
    // Check for free trial
    final trialUsed = prefs.getBool('trial_used') ?? false;
    final trialEndMs = prefs.getInt('trial_end_date');
    
    if (!trialUsed && trialEndMs == null) {
      // First time user - grant free trial
      await _startFreeTrial();
    } else if (trialEndMs != null) {
      final trialEnd = DateTime.fromMillisecondsSinceEpoch(trialEndMs);
      if (trialEnd.isAfter(DateTime.now()) && !_isPremium) {
        _isPremium = true;
        _subscriptionEndDate = trialEnd;
      }
    }
    
    notifyListeners();
  }

  Future<void> _startFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialEnd = DateTime.now().add(const Duration(days: 30));
    
    await prefs.setBool('trial_used', true);
    await prefs.setInt('trial_end_date', trialEnd.millisecondsSinceEpoch);
    
    _isPremium = true;
    _subscriptionEndDate = trialEnd;
    
    notifyListeners();
  }

  Future<void> _saveSubscriptionStatus(bool isPremium, DateTime? endDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
    
    if (endDate != null) {
      await prefs.setInt('subscription_end_date', endDate.millisecondsSinceEpoch);
    } else {
      await prefs.remove('subscription_end_date');
    }
    
    _isPremium = isPremium;
    _subscriptionEndDate = endDate;
    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        print('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver product
        _verifyPurchase(purchaseDetails);
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In production, verify purchase with your backend server
    // For now, we'll trust the purchase
    
    DateTime endDate;
    if (purchaseDetails.productID == monthlySubscriptionId) {
      endDate = DateTime.now().add(const Duration(days: 30));
    } else if (purchaseDetails.productID == yearlySubscriptionId) {
      endDate = DateTime.now().add(const Duration(days: 365));
    } else {
      return;
    }
    
    await _saveSubscriptionStatus(true, endDate);
  }

  Future<bool> buySubscription(ProductDetails productDetails) async {
    if (!_isAvailable) return false;
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    try {
      final success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
