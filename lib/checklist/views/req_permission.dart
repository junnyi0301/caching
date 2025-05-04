import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ReqPermission extends StatefulWidget {
  final Widget child; // The child widget to render after permission check
  final Function(bool)? onPermissionResult; // Callback for permission result

  const ReqPermission({
    super.key,
    required this.child,
    this.onPermissionResult,
  });

  @override
  State<ReqPermission> createState() => _ReqPermissionState();
}

class _ReqPermissionState extends State<ReqPermission> {
  bool _permissionGranted = false;
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    // Check current permission status
    final status = await Permission.notification.status;

    if (status.isGranted) {
      _handlePermissionGranted();
      return;
    }

    // Request permission if not determined
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        _handlePermissionGranted();
      } else {
        _handlePermissionDenied();
      }
    } else if (status.isPermanentlyDenied) {
      _handlePermissionDenied();
    }
  }

  void _handlePermissionGranted() {
    setState(() => _permissionGranted = true);
    widget.onPermissionResult?.call(true);
  }

  void _handlePermissionDenied() {
    widget.onPermissionResult?.call(false);
    if (!_showingDialog) {
      _showingDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionDeniedDialog(context);
      });
    }
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'Please enable notifications in Settings to receive important reminders.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              _showingDialog = false;
            },
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.pop(context);
              _showingDialog = false;
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}