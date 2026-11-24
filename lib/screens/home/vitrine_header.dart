import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/vitrine.dart';
import '../../widgets/product_image.dart';

/// FR2 — name, description, logo, contact, status.
class VitrineHeader extends StatelessWidget {
  final Vitrine vitrine;

  const VitrineHeader({super.key, required this.vitrine});

  void _showContact(BuildContext context) {
    final t = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact ${vitrine.name}', style: t.titleLarge),
              const SizedBox(height: 8),
              if (vitrine.contactPhone != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.call_outlined, color: AppColors.leaf),
                  title: Text(vitrine.contactPhone!),
                ),
              if (vitrine.contactEmail != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline_rounded, color: AppColors.leaf),
                  title: Text(vitrine.contactEmail!),
                ),
              if (vitrine.address != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined, color: AppColors.leaf),
                  title: Text(vitrine.address!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.leaf,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ProductImage(url: vitrine.logoUrl, width: 64, height: 64, radius: 18, iconSize: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vitrine.name,
                    style: t.titleLarge?.copyWith(color: Colors.white, fontSize: 19)),
                const SizedBox(height: 2),
                Text(vitrine.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(color: AppColors.leafTint)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: vitrine.isActive ? AppColors.leafTint : AppColors.citrusTint,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(vitrine.isActive ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: vitrine.isActive ? AppColors.leafDark : AppColors.citrusDark,
                          )),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _showContact(context),
                      icon: const Icon(Icons.call_outlined, size: 16),
                      label: const Text('Contact',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
