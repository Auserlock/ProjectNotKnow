enum CurrentView {
  insert,
  search,
  settings,
}

extension CurrentViewExtension on CurrentView {
  String get name {
    switch (this) {
      case CurrentView.insert:
        return 'Insert';
      case CurrentView.search:
        return 'Search';
      case CurrentView.settings:
        return 'Settings';
    }
  }
}
