import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_badge.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../state/app_state_provider.dart';

class WeeklyMenuScreen extends StatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  State<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  int _selectedDayIndex = 0;
  bool _isLunchSelected = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final weeklyMenu = appState.weeklyMenu;

    if (weeklyMenu.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        appBar: VrsAppBar(title: "Weekly Menu"),
        body: EmptyStateWidget(
          icon: Icons.menu_book_rounded,
          title: "No Weekly Menu Published",
          subtitle: "The kitchen has not published the weekly schedule yet. Please check back later.",
        ),
      );
    }

    if (_selectedDayIndex >= weeklyMenu.length) {
      _selectedDayIndex = 0;
    }
    final currentDay = weeklyMenu[_selectedDayIndex];

    final currentSabzis = _isLunchSelected ? currentDay.lunchSabzis : currentDay.dinnerSabzis;
    final currentDal = _isLunchSelected ? currentDay.lunchDal : currentDay.dinnerDal;
    final currentRotis = _isLunchSelected ? currentDay.lunchRotis : currentDay.dinnerRotis;
    final currentRice = _isLunchSelected ? currentDay.lunchRice : currentDay.dinnerRice;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Weekly Menu"),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Horizontal Day Selector
            Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
              child: SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
                  itemCount: weeklyMenu.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = weeklyMenu[index];
                    final isSelected = _selectedDayIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      borderRadius: AppDimens.borderMD,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.navyPrimary : AppColors.backgroundLight,
                          borderRadius: AppDimens.borderMD,
                          border: Border.all(
                            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected ? AppDimens.softShadow : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.dayName.substring(0, 3).toUpperCase(),
                              style: AppTypography.caption.copyWith(
                                color: isSelected ? AppColors.goldLight : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${day.date.day}",
                              style: AppTypography.titleMedium.copyWith(
                                color: isSelected ? AppColors.textWhite : AppColors.navyPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Lunch vs Dinner Segment Toggle
            Padding(
              padding: const EdgeInsets.all(AppDimens.space16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppDimens.borderFull,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isLunchSelected = true),
                        borderRadius: AppDimens.borderFull,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isLunchSelected ? AppColors.goldBackground : Colors.transparent,
                            borderRadius: AppDimens.borderFull,
                            border: _isLunchSelected
                                ? Border.all(color: AppColors.goldPrimary)
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_sunny_rounded,
                                size: 16,
                                color: _isLunchSelected ? AppColors.goldDark : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Lunch (12 - 2 PM)",
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: _isLunchSelected ? FontWeight.bold : FontWeight.w500,
                                  color: _isLunchSelected ? AppColors.navyDark : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isLunchSelected = false),
                        borderRadius: AppDimens.borderFull,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isLunchSelected ? AppColors.navyPrimary : Colors.transparent,
                            borderRadius: AppDimens.borderFull,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 16,
                                color: !_isLunchSelected ? AppColors.goldLight : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Dinner (8 - 10 PM)",
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: !_isLunchSelected ? FontWeight.bold : FontWeight.w500,
                                  color: !_isLunchSelected ? AppColors.textWhite : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Menu Offerings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${currentDay.dayName}'s ${_isLunchSelected ? 'Lunch' : 'Dinner'} Menu",
                        style: AppTypography.headingMedium,
                      ),
                      const VegBadge(size: 16),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space12),

                  // Sabzi Options
                  Text("Choice of Fresh Sabzi", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (currentSabzis.isEmpty)
                    _buildMenuCard(
                      title: "Chef's Special Sabzi",
                      description: "Freshly prepared seasonal homestyle vegetable",
                      category: "Sabzi",
                      tag: "Chef's Choice",
                    )
                  else
                    ...currentSabzis.map((item) => _buildMenuCard(
                      title: item.name,
                      description: item.description,
                      category: "Sabzi",
                      tag: "Chef's Choice",
                    )),

                  const SizedBox(height: AppDimens.space16),

                  // Dal
                  Text("Lentils & Dal", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    title: currentDal.name.isNotEmpty ? currentDal.name : "Dal Tadka",
                    description: currentDal.description.isNotEmpty ? currentDal.description : "Slow cooked homestyle dal",
                    category: "Dal",
                    tag: "Slow-Cooked",
                  ),

                  const SizedBox(height: AppDimens.space16),

                  // Roti & Rice
                  Text("Breads & Rice", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    title: "${currentRotis.isNotEmpty ? currentRotis.first.name : 'Butter Roti'} & ${currentRice.isNotEmpty ? currentRice.first.name : 'Jeera Rice'}",
                    description: "5 phulkas made from MP Sharbati wheat flour and aged basmati rice.",
                    category: "Accompaniment",
                    tag: "100% Desi Ghee",
                  ),

                  const SizedBox(height: AppDimens.space24),

                  // Customize Button CTA
                  VrsButton(
                    text: "Customize For ${currentDay.dayName}",
                    icon: const Icon(Icons.tune_rounded, color: AppColors.navyDark, size: 18),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.mealCustomizer),
                    variant: VrsButtonVariant.gold,
                  ),

                  const SizedBox(height: AppDimens.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String description,
    required String category,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppDimens.borderMD,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppDimens.softShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppDimens.borderSM,
            child: Image.asset(
              "assets/images/thali_special.png",
              width: 65,
              height: 65,
              fit: BoxFit.cover,
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
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.navyPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.caption.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
