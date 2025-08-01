import 'package:flutter/foundation.dart';

class CountProvider with ChangeNotifier {
  bool _isconnect = false;
  bool _isLoading = false;
  bool _isConnected = false;

  int _progressPercentage = 0;

  bool get isconnect => _isconnect;

  bool get isLoading => _isLoading;

  bool get isConnected => _isConnected;

  void setCount(bool v) {
    _isconnect = v;
    notifyListeners();
  }
  void _startLoading() {
   _isLoading = true;
    _updateProgress();
    notifyListeners();
  }

 void _updateProgress() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_progressPercentage < 100) {
        _progressPercentage += 10;
        _updateProgress();
        notifyListeners();
      } else {
        _isLoading = false;
        _isConnected = true;
        notifyListeners();
      }
      notifyListeners();
    });
  }

  void _disconnect() async{
    _isConnected = false;
    _progressPercentage = 0;
     notifyListeners();
  }
}
