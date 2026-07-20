import 'package:flutter/material.dart';
import 'home_theme.dart';
import 'views/home_tab_shell.dart';

class HomeFacade {
  Widget buildRoot() {
    return Theme(
      data: HomeTheme.light(),
      child: const HomeTabShell(),
    );
  }
}
