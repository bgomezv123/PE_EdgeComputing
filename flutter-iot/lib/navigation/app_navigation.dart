import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iotflutter/uis/main_wrapper.dart';
import 'package:iotflutter/uis/screenData/screenViewScrollDataSensor.dart';
import 'package:iotflutter/uis/publishData/screenPublishScreen.dart';
import 'package:iotflutter/uis/screenData/screenViewDataImage.dart';
import 'package:iotflutter/uis/subscriteData/screenSubscribeScreen.dart';

class AppNavigation {
  AppNavigation._();

  static String initial = "/home";

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorDataSensor =
      GlobalKey<NavigatorState>(debugLabel: 'shellDataSensor');
  static final _shellNavigatorDataImage =
      GlobalKey<NavigatorState>(debugLabel: 'shellDataImage');

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: initial,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      /// MainWrapper
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          /// Brach Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: <RouteBase>[
              GoRoute(
                  path: "/home",
                  name: "Home",
                  builder: (BuildContext context, GoRouterState state) =>
                      const MqttPublishScreen()),
            ],
          ),

          /// Brach Setting
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDataSensor,
            routes: <RouteBase>[
              GoRoute(
                path: "/sensorData",
                name: "SensorData",
                builder: (BuildContext context, GoRouterState state) =>
                    ScreenViewDataSensor(),
              ),
            ],
          ),

          /// Brach Setting
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDataImage,
            routes: <RouteBase>[
              GoRoute(
                path: "/imageData",
                name: "imageData",
                builder: (BuildContext context, GoRouterState state) =>
                    const MqttSubscribeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
