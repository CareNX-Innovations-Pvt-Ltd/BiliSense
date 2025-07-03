import 'package:bili_sense/presentation/test_history/test_history_cubit.dart';
import 'package:bili_sense/presentation/widget/test_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestHistoryView extends StatelessWidget {
  const TestHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<TestHistoryCubit>().fetchAllTests();
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<TestHistoryCubit, TestHistoryState>(
          builder: (context, state) {
            if (state is TestHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TestHistoryError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            if (state is TestHistorySuccess) {
              final tests = state.testHistories;
              if (tests.isEmpty) {
                return const Center(child: Text('No tests found.'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        return TestHistoryCard(test: tests[index]);
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('No Test History Available'));
          },
        ),
      ),
    );
  }
}
