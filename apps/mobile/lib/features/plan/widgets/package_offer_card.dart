import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../data/package_model.dart';

class PackageOfferCard extends StatelessWidget {
  final TraverzaPackage package;
  final VoidCallback onTap;
  final VoidCallback onCustomize;
  final VoidCallback? onBook;
  final double? cardWidth;

  const PackageOfferCard({
    super.key,
    required this.package,
    required this.onTap,
    required this.onCustomize,
    this.onBook,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isOperator = package.isOperatorPackage;

    return Container(
      width: cardWidth ?? 320,
      margin: const EdgeInsets.only(right: 14, top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOperator
              ? TraverzaColors.secondary.withValues(alpha: 0.3)
              : TraverzaColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag: Type & Fit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOperator
                          ? TraverzaColors.primary.withValues(alpha: 0.08)
                          : TraverzaColors.sand.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOperator
                            ? TraverzaColors.primary.withValues(alpha: 0.2)
                            : TraverzaColors.rating.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOperator ? Icons.verified_outlined : Icons.lightbulb_outline,
                          size: 12,
                          color: isOperator ? TraverzaColors.primary : TraverzaColors.text,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOperator ? 'OPERATOR PACKAGE' : 'ITINERARY TEMPLATE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isOperator ? TraverzaColors.primary : TraverzaColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: TraverzaColors.rating),
                      const SizedBox(width: 2),
                      Text(
                        '${package.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Package Title
              Text(
                package.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TraverzaColors.text,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Corridor / destinations
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: TraverzaColors.secondary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      package.corridorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Provider & SLTDA badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      package.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
                    ),
                  ),
                  if (package.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SLTDA Lic',
                        style: TextStyle(fontSize: 8.5, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Inclusions preview
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: TraverzaColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Includes: ${package.inclusions.take(2).join(" • ")}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              // Price and Actions
              const Divider(color: TraverzaColors.border, height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOperator ? 'From' : 'Estimated',
                          style: const TextStyle(fontSize: 9.5, color: TraverzaColors.textMuted),
                        ),
                        Text(
                          'LKR ${package.basePriceLkr.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TraverzaColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: onCustomize,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(color: TraverzaColors.secondary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isOperator ? 'Customize' : 'Build Route',
                          style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isOperator && onBook != null) ...[
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TraverzaColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
