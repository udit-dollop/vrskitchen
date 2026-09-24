import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/user_model.dart';
import '../../../state/app_state_provider.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  void _showAddAddressDialog(BuildContext context) {
    final tagCtrl = TextEditingController(text: "Home");
    final addrCtrl = TextEditingController();
    final landCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLG),
        title: Text("Add New Delivery Address", style: AppTypography.headingSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagCtrl,
                decoration: const InputDecoration(labelText: "Tag (e.g. Office, Flat, Gym)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: "Street & Building Address"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: landCtrl,
                decoration: const InputDecoration(labelText: "Landmark & City"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (addrCtrl.text.trim().isNotEmpty) {
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                appState.addAddress(
                  AddressModel(
                    id: "ADDR_${DateTime.now().millisecondsSinceEpoch % 1000}",
                    tag: tagCtrl.text.trim().isEmpty ? "Location" : tagCtrl.text.trim(),
                    addressLine: addrCtrl.text.trim(),
                    landmark: landCtrl.text.trim(),
                  ),
                );
                Navigator.pop(ctx);
                UiHelpers.showSuccessSnackbar(context, "Address added successfully!");
              }
            },
            child: const Text("Save Address"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final addresses = appState.user.addresses;
    final selectedId = appState.user.selectedAddressId;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Delivery Addresses", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            Text("Saved Locations", style: AppTypography.headingMedium),
            const SizedBox(height: 4),
            Text(
              "Select where you want your lunch and dinner delivered.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimens.space16),

            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.goldBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_off_outlined, color: AppColors.goldDark, size: 36),
                      ),
                      const SizedBox(height: AppDimens.space16),
                      Text("No Saved Addresses", style: AppTypography.titleMedium.copyWith(color: AppColors.navyPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        "Add your home or office address to start receiving daily meals.",
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...addresses.map((addr) {
                final isSelected = addr.id == selectedId;
                return VrsCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppDimens.space16),
                backgroundColor: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
                border: Border.all(
                  color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
                  width: isSelected ? 1.8 : 1.0,
                ),
                onTap: () {
                  appState.updateUserProfile(selectedAddressId: addr.id);
                  UiHelpers.showSuccessSnackbar(context, "Selected ${addr.tag} as default address");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.goldPrimary : AppColors.navyPrimary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        addr.tag.toLowerCase().contains("office") ? Icons.business_rounded : Icons.home_rounded,
                        color: isSelected ? AppColors.navyDark : AppColors.navyPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                addr.tag,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "DEFAULT",
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.navyDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr.addressLine, style: AppTypography.bodySmall),
                          if (addr.landmark.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(addr.landmark, style: AppTypography.caption),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimens.space16),

            VrsButton(
              text: "+ Add New Address",
              onPressed: () => _showAddAddressDialog(context),
              variant: VrsButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
