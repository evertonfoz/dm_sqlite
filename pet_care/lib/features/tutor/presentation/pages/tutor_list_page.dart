import 'package:flutter/material.dart';
import 'package:pet_care/core/presentation/widgets/app_drawer.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_form_page.dart';

import '../widgets/list/empty_tutors.dart';
import '../widgets/list/tutor_dismissible_item.dart';

class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});

  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  final TutorController _controller = TutorController();

  @override
  void initState() {
    super.initState();
    _controller.getAllTutors();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutores',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0F766E),
              ),
            ),
            Text(
              'Gerencie os responsáveis pelos pets',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        actions: [
          IconButton(
            onPressed: _controller.getAllTutors,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F766E)),
            tooltip: 'Atualizar Lista',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(activeRoute: 'tutors'),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading || _controller.isDeleting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F766E),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando tutores...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }

          if (_controller.tutors.isEmpty) {
            return const EmptyTutorsToListView();
          }

          return RefreshIndicator(
            onRefresh: _controller.getAllTutors,
            color: const Color(0xFF0F766E),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: _controller.tutors.length,
              itemBuilder: (context, index) {
                final tutor = _controller.tutors[index];
                return TutorDismissibleItem(tutor, _controller);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const TutorFormPage()),
          );
          if (result == true) {
            _controller.getAllTutors();
          }
        },
        backgroundColor: const Color(0xFFF97316),
        elevation: 4,
        label: const Text(
          'Novo Tutor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
