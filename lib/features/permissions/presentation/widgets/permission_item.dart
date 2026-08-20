import 'package:flutter/material.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/permission_card.dart';

class PermissionItemWidget extends StatelessWidget {
  final AppPermissionType permissionType;
  final AppPermissionStatus status;
  final VoidCallback onRequest;

  const PermissionItemWidget({
    super.key,
    required this.permissionType,
    required this.status,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionCard(
      permissionType: permissionType,
      status: status,
      onTap: onRequest,
    );
  }
}
