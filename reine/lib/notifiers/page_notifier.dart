import '../views/views.dart';

class PageNotifier {
  var _currentPage = CurrentView.insert;

  String get currentPageName => _currentPage.name;
  CurrentView get currentPage => _currentPage;

  void setCurrentPage(CurrentView page) async {
    _currentPage = page;
  }
}
