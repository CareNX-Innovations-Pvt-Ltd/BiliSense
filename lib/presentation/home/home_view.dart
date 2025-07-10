import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_cubit.dart';
import 'package:bili_sense/presentation/widget/icon_tile.dart';
import 'package:bili_sense/presentation/widget/register_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    debugPrint('Home View built with user: ${prefs.userModel.name}');
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state is HomeNavigationState) {
                final tests = context.read<MotherDetailsCubit>().tests;
                context.pushNamed(
                  AppRoutes.bluetooth,
                  extra: {'motherModel': state.motherModel, 'tests': tests},
                );
              }
            },
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InfoTile(
                                title: 'Total Tests Taken',
                                value:
                                    context
                                        .read<HomeCubit>()
                                        .totalTests
                                        .toString(),
                              ),
                              InfoTile(
                                title: 'Newborns',
                                value:
                                    context
                                        .read<HomeCubit>()
                                        .totalNewborns
                                        .toString(),
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
                      backgroundColor: Colors.teal.shade700,
                      fixedSize: Size(double.maxFinite, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => showMotherRegistrationDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 24),
                        const SizedBox(width: 2),
                        const Text(
                          'Add Newborn',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
