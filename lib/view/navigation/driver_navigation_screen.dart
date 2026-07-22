import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({super.key});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  bool _initialized = false;
  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateNavigationCamera(rideProvider);
        });
        return Scaffold(
          body: Stack(
            children: [
              /// Navigation View
              Positioned.fill(
                child: MapWidget(
                  key: const ValueKey("driver-map"),
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                  onMapCreated: (MapboxMap mapboxMap) async {
                    _mapboxMap = mapboxMap;

                    await mapboxMap.location.updateSettings(
                      LocationComponentSettings(
                        enabled: true,
                        pulsingEnabled: true,
                        puckBearingEnabled: true,
                        puckBearing: PuckBearing.HEADING,
                      ),
                    );

                    await mapboxMap.scaleBar.updateSettings(
                      ScaleBarSettings(enabled: false),
                    );

                    await mapboxMap.logo.updateSettings(
                      LogoSettings(enabled: false),
                    );

                    await mapboxMap.attribution.updateSettings(
                      AttributionSettings(enabled: false),
                    );

                    await mapboxMap.compass.updateSettings(
                      CompassSettings(enabled: false),
                    );
                  },
                ),
              ),

              /// Top Navigation Banner
              if (rideProvider.orderData != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rideProvider.inDelivery
                                  ? "Deliver to customer"
                                  : "Navigate to restaurant",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              /// Online Button
              Positioned(
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () async {
                    if (rideProvider.isOnline) {
                      await rideProvider.goOffline();
                    } else {
                      await rideProvider.goOnline();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 16,
                          color: rideProvider.isOnline
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          rideProvider.isOnline ? "ONLINE" : "OFFLINE",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateNavigationCamera(RideProvider provider) {
    if (_mapboxMap == null || provider.currentPosition == null) return;

    final position = provider.currentPosition!;

    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 19.2,
        bearing: position.heading,
        pitch: 75,
      ),
      MapAnimationOptions(duration: 800),
    );
  }
}
