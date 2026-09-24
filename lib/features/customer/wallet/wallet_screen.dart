import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/wallet_transaction_model.dart';
import '../../../state/app_state_provider.dart';

class WalletScreen extends StatelessWidget {
  final bool showBack;

  const WalletScreen({super.key, this.showBack = true});

  void _showAddMoneyModal(BuildContext context) {
    int selectedAmount = 200;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppDimens.space24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radiusXL),
                  topRight: Radius.circular(AppDimens.radiusXL),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.space20),
                    Text("Top-up Flexi Wallet", style: AppTypography.headingMedium),
                    Text(
                      "Add balance to pay for daily add-ons or future subscriptions",
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppDimens.space20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [100, 200, 500].map((amt) {
                        final isSelected = selectedAmount == amt;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setModalState(() => selectedAmount = amt),
                              borderRadius: AppDimens.borderMD,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.goldBackground : AppColors.backgroundLight,
                                  borderRadius: AppDimens.borderMD,
                                  border: Border.all(
                                    color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "₹$amt",
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.navyDark : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppDimens.space24),

                    VrsButton(
                      text: "Add ₹$selectedAmount to Wallet",
                      onPressed: () {
                        final appState = Provider.of<AppStateProvider>(context, listen: false);
                        appState.addWalletTransaction(
                          title: "Added Money via UPI",
                          description: "Instant wallet top-up",
                          amount: selectedAmount.toDouble(),
                          type: TransactionType.credit,
                        );
                        Navigator.pop(context);
                        UiHelpers.showSuccessSnackbar(context, "₹$selectedAmount added to Flexi Wallet!");
                      },
                      variant: VrsButtonVariant.gold,
                    ),
                    const SizedBox(height: AppDimens.space12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final balance = appState.walletBalance;
    final transactions = appState.walletTransactions;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: VrsAppBar(title: "Flexi Wallet", showBack: showBack),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Wallet Gradient Hero Card
            Container(
              padding: const EdgeInsets.all(AppDimens.space24),
              decoration: BoxDecoration(
                gradient: AppColors.navyCardGradient,
                borderRadius: AppDimens.borderXL,
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 1.2),
                boxShadow: AppDimens.navyShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.goldLight,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "VR's Flexi Wallet",
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: AppDimens.borderFull,
                        ),
                        child: Text(
                          "Active & Safe",
                          style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space24),

                  Text(
                    "Available Balance",
                    style: AppTypography.caption.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        UiHelpers.formatCurrency(balance),
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMoneyModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: AppColors.navyDark,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: AppDimens.borderFull),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text(
                          "Add Money",
                          style: AppTypography.button.copyWith(
                            fontSize: 13,
                            color: AppColors.navyDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: AppDimens.borderMD,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.goldLight, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Paused meal credits (₹80/meal) automatically refund here.",
                            style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction History", style: AppTypography.headingMedium),
                Text("${transactions.length} records", style: AppTypography.caption),
              ],
            ),
            const SizedBox(height: AppDimens.space12),

            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimens.space32),
                child: Center(
                  child: Text(
                    "No transactions yet\nYour paused meal credits will appear here.",
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...transactions.map((txn) {
                final isCredit = txn.type == TransactionType.credit;
                return VrsCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(AppDimens.space14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? AppColors.vegGreen.withValues(alpha: 0.12)
                              : AppColors.statusError.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? AppColors.vegGreen : AppColors.statusError,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.title,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(txn.description, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${isCredit ? '+' : '-'} ₹${txn.amount.toInt()}",
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isCredit ? AppColors.vegGreen : AppColors.navyPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year}",
                            style: AppTypography.caption.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}
