import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:bili_sense/presentation/widget/icon_tile.dart';
import 'package:bili_sense/presentation/widget/register_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final prefs = getIt<SharedPreferenceHelper>();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is HomeError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (state is HomeLoaded && state.recentTests.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          color: Colors.grey[300],
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Text(
                                  'Hello, Dr. ${prefs.userModel.name}!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InfoTile(
                                      title: 'Total Tests Taken',
                                      value: state.totalTests,
                                    ),
                                    InfoTile(
                                      title: 'Newborns',
                                      value: state.totalNewborns,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: Size(constraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed:
                              () => showMotherRegistrationDialog(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 24),
                              const SizedBox(width: 2),
                              const Text(
                                'Add Newborn',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text(
                        //       'Recent additions:',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //     Container(
                        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        //       decoration: BoxDecoration(
                        //         color: Colors.black38,
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       child: InkWell(
                        //         onTap:
                        //             () => context.push(AppRoutes.allNewborns),
                        //         child: const Text(
                        //           'View All',
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //             color: Colors.white,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Expanded(
                        //   child: ListView.builder(
                        //     itemCount: state.recentTests.length,
                        //     itemBuilder: (context, index) {
                        //       final mother = state.recentTests[index];
                        //       return NewbornListTile(
                        //         model: mother,
                        //         onTap: () {
                        //           context.push(
                        //             AppRoutes.motherDetails,
                        //             extra: mother,
                        //           );
                        //         },
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    );
                  }
                  return const Center(
                    child: Text(
                      'No records found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
