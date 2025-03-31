import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:controller/src/controllers/network/connectivity_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/statistics/statistics_controller.dart';
import '../goals/goal_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<StatisticsController>(context, listen: false)
        .getStatistics(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var provider = Provider.of<StatisticsController>(context);
    return DefaultTabController(
      length: 4,
      child: Consumer<ConnectivityController>(
          builder: (context, connectivityController, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.statistics),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            bottom: TabBar(
              onTap: (val) {
                provider.setDateFilter(
                  val == 0
                      ? 'Today'
                      : val == 1
                          ? 'Week'
                          : val == 2
                              ? 'Month'
                              : 'Year',
                );
                provider.getStatistics(context);
              },
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.grey.withOpacity(0.5),
              labelColor: Theme.of(context).primaryColor,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
              ),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontFamily: 'Airbnb',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Airbnb',
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              physics: const NeverScrollableScrollPhysics(),
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Week'),
                Tab(text: 'Month'),
                Tab(text: 'Year'),
              ],
            ),
          ),
          body: provider.withoutData && !provider.loading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.noGoals,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.configureGoals,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PrincipalButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GoalsScreen(),
                              ),
                            ).then((value) {
                              provider.getStatistics(context);
                            });
                          },
                          text: AppLocalizations.of(context)!
                              .configureGoalsButton,
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  onRefresh: () async {
                    provider.getStatistics(context);
                  },
                  child: const SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        WarmCaloriesWidget(),
                        Row(
                          children: [
                            SitTimeWidget(),
                            SitMidWidget(),
                            StandUpTimeWidget(),
                          ],
                        ),
                        GoalsWidget(),
                        MostUsedMemoriesWidget(),
                        SizedBox(
                          height: 90,
                        ),
                      ],
                    ),
                  ),
                ),

          //  TabBarView(
          //     children: List.generate(4, (index) {
          //   // Mismo widget reutilizado
          //   return RefreshIndicator(
          //     color: Colors.white,
          //     backgroundColor: Theme.of(context).primaryColor,
          //     onRefresh: () async {
          //       provider.getStatistics(context);
          //     },
          //     child: const SingleChildScrollView(
          //       child: Column(
          //         children: [
          //           SizedBox(
          //             height: 5,
          //           ),
          //           WarmCaloriesWidget(),
          //           Row(
          //             children: [
          //               SitTimeWidget(),
          //               SitMidWidget(),
          //               StandUpTimeWidget(),
          //             ],
          //           ),
          //           GoalsWidget(),
          //           MostUsedMemoriesWidget(),
          //           SizedBox(
          //             height: 90,
          //           ),
          //         ],
          //       ),
          //     ),
          //   );
          // })
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class StandUpTimeWidget extends StatelessWidget {
  const StandUpTimeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).cardTheme.shadowColor!,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 45,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.timeStanding,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                      )),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                color: Theme.of(context).cardTheme.surfaceTintColor,
              ),
              const SizedBox(
                height: 5,
              ),
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/stand_up.png',
                      width: 30,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              provider.loading
                  ? Shimmer.fromColors(
                      baseColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      highlightColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      period: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          height: 20.0,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ))
                  : Text(
                      provider.formatDuration(
                          provider.statistics!.result!.timeStandingInSeconds!),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SitTimeWidget extends StatelessWidget {
  const SitTimeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).cardTheme.shadowColor!,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 45,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.timeSitting,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color:
                              Theme.of(context).textTheme.displayLarge!.color)),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                color: Theme.of(context).cardTheme.surfaceTintColor,
              ),
              const SizedBox(
                height: 5,
              ),
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/sitting.png',
                      width: 30,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              provider.loading
                  ? Shimmer.fromColors(
                      baseColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      highlightColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      period: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          height: 20.0,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ))
                  : Text(
                      provider.formatDuration(
                          provider.statistics!.result!.timeSeatedInSeconds!),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//sitMidWidget
class SitMidWidget extends StatelessWidget {
  const SitMidWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).cardTheme.shadowColor!,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 45,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.timeRest,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color:
                              Theme.of(context).textTheme.displayLarge!.color)),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                color: Theme.of(context).cardTheme.surfaceTintColor,
              ),
              const SizedBox(
                height: 5,
              ),
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/rest.png',
                      width: 30,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              provider.loading
                  ? Shimmer.fromColors(
                      baseColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      highlightColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      period: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          height: 20.0,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ))
                  : Text(
                      provider.formatDuration(
                          provider.statistics!.result!.timeMidInSeconds!),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WarmCaloriesWidget extends StatelessWidget {
  const WarmCaloriesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardTheme.shadowColor!,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.caloriesBurned,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    )),
                // trailing: const Icon(
                //   Icons.arrow_forward_ios_rounded,
                //   size: 14,
                // ),
              ),
            ),
            Divider(
              color: Theme.of(context).cardTheme.surfaceTintColor,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    radius: 40,
                    child: Icon(
                      Icons.fireplace_rounded,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      provider.loading
                          ? Shimmer.fromColors(
                              baseColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              highlightColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              period: const Duration(milliseconds: 400),
                              child: Container(
                                height: 30.0,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ))
                          : Text(
                              '${provider.statistics!.result!.caloriesBurned!.toStringAsFixed(1)} cal',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class GoalsWidget extends StatelessWidget {
  const GoalsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardTheme.shadowColor!,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalsScreen(),
                  ),
                );
              },
              child: SizedBox(
                height: 45,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.goals,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                      )),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).cardTheme.surfaceTintColor,
            ),
            const SizedBox(
              height: 5,
            ),
            if (provider.statistics != null)
              Row(
                children: [
                  GoalChildWidget(
                    title: AppLocalizations.of(context)!.timeSitting,
                    value:
                        "${provider.formatDuration(provider.statistics!.result!.timeSeatedInSeconds!)} / ${provider.formatDuration(provider.statistics!.result!.iSittingTimeSecondsGoal!)}",
                    icon: Icons.chair,
                    asset: 'assets/images/icons/sitting.png',
                  ),
                  GoalChildWidget(
                    title: AppLocalizations.of(context)!.timeStanding,
                    value:
                        "${provider.formatDuration(provider.statistics!.result!.timeStandingInSeconds!)} / ${provider.formatDuration(provider.statistics!.result!.iStandingTimeSecondsGoal!)}",
                    icon: Icons.directions_walk,
                    asset: 'assets/images/icons/stand_up.png',
                  ),
                  GoalChildWidget(
                    title: AppLocalizations.of(context)!.caloriesBurned,
                    value:
                        "${provider.statistics!.result!.caloriesBurned!.toStringAsFixed(1)} / ${provider.statistics!.result!.iCaloriesToBurnGoal!.toStringAsFixed(1)}",
                    icon: FontAwesomeIcons.fire,
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class GoalChildWidget extends StatelessWidget {
  const GoalChildWidget({
    super.key,
    this.title,
    this.value,
    this.icon,
    this.asset,
  });

  final String? title;
  final String? value;
  final IconData? icon;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            radius: 50,
            child: asset != null
                ? Image.asset(
                    asset!,
                    width: 30,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                  )
                : Icon(
                    icon,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                    size: 30,
                  ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge!.color,
            ),
          ),
          provider.loading
              ? Shimmer.fromColors(
                  baseColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  highlightColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  period: const Duration(milliseconds: 400),
                  child: Container(
                    height: 20.0,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ))
              : Text(
                  value!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
        ],
      ),
    );
  }
}

class MostUsedMemoriesWidget extends StatelessWidget {
  const MostUsedMemoriesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardTheme.shadowColor!,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: ListTile(
                title: Text(
                    AppLocalizations.of(context)!.mostUsedMemoryPosition,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    )),
              ),
            ),
            Divider(
              color: Theme.of(context).cardTheme.surfaceTintColor,
            ),
            const SizedBox(
              height: 5,
            ),
            if (provider.statistics != null)
              Row(
                children: provider.statistics!.result!.memoriMoreUse!
                    .split(',')
                    .map((e) {
                  return MemoryChildWidget(
                    value: e,
                    icon: Icons.directions_walk,
                  );
                }).toList(),
              ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryChildWidget extends StatelessWidget {
  const MemoryChildWidget({
    super.key,
    this.value,
    this.icon,
  });

  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StatisticsController>(context);
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            radius: 50,
            child: provider.loading
                ? Shimmer.fromColors(
                    baseColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    period: const Duration(milliseconds: 400),
                    child: Container(
                      height: 40.0,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ))
                : Image.asset(
                    value! == "3"
                        ? 'assets/images/icons/sitting.png'
                        : value! == "2"
                            ? 'assets/images/icons/rest.png'
                            : 'assets/images/icons/stand_up.png',
                    width: 30,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                  ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value! == "3"
                ? "$value° ${AppLocalizations.of(context)!.sittingMemory}"
                : value! == "2"
                    ? "$value° ${AppLocalizations.of(context)!.restMemory}"
                    : "$value° ${AppLocalizations.of(context)!.standingMemory}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
