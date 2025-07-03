import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_cubit.dart';
import 'package:bili_sense/presentation/widget/test_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MotherDetailsView extends StatefulWidget {
  final MotherModel motherModel;

  const MotherDetailsView({super.key, required this.motherModel});

  @override
  State<MotherDetailsView> createState() => _MotherDetailsViewState();
}

class _MotherDetailsViewState extends State<MotherDetailsView> {
  void fetchTests() {
    context.read<MotherDetailsCubit>().fetchTests(
      widget.motherModel.motherName,
    );
  }

  List<TestModel> get tests => context.read<MotherDetailsCubit>().tests;

  @override
  void initState() {
    fetchTests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.motherModel.motherName),
              InkWell(
                onTap: () {
                  context.push(
                    AppRoutes.report,
                    extra: {
                      'motherModel': widget.motherModel,
                      'tests': tests,
                    },
                  );
                },
                child: Text(
                  'View Report',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),

        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: BlocBuilder<MotherDetailsCubit, MotherDetailsState>(
            builder: (context, state) {
              if (state is MotherDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MotherDetailsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              if (state is MotherDetailsSuccess) {
                if (state.tests.isEmpty) {
                  return Center(
                    child: Text(
                      'No tests found for ${widget.motherModel.motherName}',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.tests.length,
                  itemBuilder: (context, index) {
                    final test = state.tests[index];
                    return TestCard(test: test);
                  },
                );
              }
              return Center(
                child: Text(
                  'No tests available, please add a new test.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            context.push(
              AppRoutes.bluetooth,
              extra: {'motherModel': widget.motherModel, 'tests': tests},
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.launch),
              const SizedBox(width: 8),
              const Text('New Test'),
            ],
          ),
        ),
      ),
    );
  }
}
