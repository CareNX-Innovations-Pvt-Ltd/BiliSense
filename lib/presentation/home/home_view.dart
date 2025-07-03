import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:bili_sense/presentation/widget/icon_tile.dart';
import 'package:bili_sense/presentation/widget/newborn_list_tile.dart';
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
                        const Text(
                          'Welcome to BiliSense',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent additions:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () => context.push(AppRoutes.allNewborns),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.recentTests.length,
                            itemBuilder: (context, index) {
                              final mother = state.recentTests[index];
                              return NewbornListTile(
                                model: mother,
                                onTap: () {
                                  context.push(
                                    AppRoutes.motherDetails,
                                    extra: mother,
                                  );
                                },
                              );
                            },
                          ),
                        ),
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
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            maximumSize: const Size(180, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: () => showMotherRegistrationDialog(context),
          child: Row(
            children: [
              Icon(Icons.add),
              const SizedBox(width: 2),
              const Text('Add Newborn', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
