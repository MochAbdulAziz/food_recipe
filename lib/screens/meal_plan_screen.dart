import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../bloc/meal_plan/meal_plan_state.dart';
import '../models/recipe.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.textDark),
                    ),
                    Text(
                      'Meal Planner',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 8),
                // Calendar
                BlocBuilder<MealPlanCubit, MealPlanState>(
                  builder: (context, planState) {
                    return TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                      calendarFormat: CalendarFormat.week,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      availableCalendarFormats: const {
                        CalendarFormat.week: 'Week',
                        CalendarFormat.month: 'Month',
                      },
                      eventLoader: (day) {
                        final key = MealPlanCubit.dayKey(day);
                        return planState.plan[key] ?? [];
                      },
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: const BoxDecoration(
                          color: AppColors.chipBg,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.accentSalmon,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textDark),
                        weekendTextStyle: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.accentSalmon),
                        outsideTextStyle: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textLight),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonDecoration: BoxDecoration(
                          color: AppColors.bgMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        formatButtonTextStyle: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textMid),
                        titleTextStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                        leftChevronIcon: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textMid),
                        rightChevronIcon: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMid),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight),
                        weekendStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentSalmon),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Selected day's meal list
          Expanded(
            child: BlocBuilder<MealPlanCubit, MealPlanState>(
              builder: (context, planState) {
                final recipes =
                    context.read<MealPlanCubit>().recipesForDay(_selectedDay);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DayHeader(day: _selectedDay, count: recipes.length),
                    const SizedBox(height: 8),
                    if (recipes.isEmpty)
                      _buildDayEmpty(context)
                    else
                      ...recipes.map((r) => _MealPlanCard(
                            recipe: r,
                            day: _selectedDay,
                          )),
                    const SizedBox(height: 8),
                    _buildAddButton(context),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No meals planned. Tap + to add a recipe.',
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showRecipePicker(context),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text('Add recipe for this day',
          style: GoogleFonts.poppins(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _showRecipePicker(BuildContext context) {
    final homeState = context.read<HomeCubit>().state;
    final recipes = homeState is HomeLoaded ? homeState.foodItems : <FoodItemData>[];
    final cubit = context.read<MealPlanCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pick a recipe',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: recipes.isEmpty
                    ? Center(
                        child: Text('No recipes loaded.',
                            style: GoogleFonts.poppins(
                                color: AppColors.textLight)))
                    : ListView.separated(
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xFFEDE8E3)),
                        itemBuilder: (ctx, i) {
                          final r = recipes[i];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: AppRemoteImage(imageUrl: r.imageUrl),
                              ),
                            ),
                            title: Text(r.title,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                            subtitle: Text(r.prepTime,
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: AppColors.textLight)),
                            onTap: () {
                              cubit.assignRecipe(_selectedDay, r);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final int count;

  const _DayHeader({required this.day, required this.count});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[(day.weekday - 1) % 7];
    final label =
        '$weekday, ${months[day.month - 1]} ${day.day}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (count > 0)
          Text(
            '$count meal${count > 1 ? 's' : ''}',
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textLight),
          ),
      ],
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  final FoodItemData recipe;
  final DateTime day;

  const _MealPlanCard({required this.recipe, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: AppRemoteImage(imageUrl: recipe.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipe.prepTime} · ${recipe.calories}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                context.read<MealPlanCubit>().removeRecipe(day, recipe.title),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.accentSalmon),
            ),
          ),
        ],
      ),
    );
  }
}
