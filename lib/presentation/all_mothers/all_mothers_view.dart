import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/presentation/all_mothers/all_mother_cubit.dart';
import 'package:bili_sense/presentation/widget/newborn_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AllMothersView extends StatefulWidget {
  const AllMothersView({super.key});

  @override
  State<AllMothersView> createState() => _AllMothersViewState();
}

class _AllMothersViewState extends State<AllMothersView> {
  @override
  void initState() {
    context.read<AllMotherCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search Mothers',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                ),
                onChanged: (value) {
                  context.read<AllMotherCubit>().searchMothers(value);
                },
              ),
              BlocBuilder<AllMotherCubit, AllMotherState>(
                builder: (context, state) {
                  if (state is AllMotherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AllMotherError) {
                    return Center(
                      child: Text(
                        state.message,
                      ),
                    );
                  }
                  if (state is AllMotherSuccess) {
                    if (state.mothers.isEmpty) {
                      return const Center(
                        child: Text('No mothers found.'),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.mothers.length,
                        itemBuilder: (context, index) {
                          final mother = state.mothers[index];
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
                    );
                  }
                  return const Center(child: Text('No mothers found.'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
