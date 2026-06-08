import 'package:flutter/material.dart';
import 'package:pet_care/core/presentation/widgets/app_drawer.dart';
import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';
import 'package:pet_care/features/pet/presentation/controllers/pet_controller.dart';
import 'package:pet_care/features/pet/presentation/pages/pet_form_page.dart';
import 'package:pet_care/features/pet/presentation/widgets/list/dismissible_item.dart';

import '../widgets/list/empty_pets.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  late PetController _controller;
  late PetRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = SqlitePetRepository(SqflitePetLocalDataSource());
    _controller = PetController(repository: _repository);
    _controller.getAllPets();
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
      drawer: const AppDrawer(activeRoute: 'pets'),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Care',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0F766E),
              ),
            ),
            Text(
              'Gerencie seus melhores amigos',
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
            onPressed: _controller.getAllPets,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F766E)),
            tooltip: 'Atualizar Lista',
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                  Text(
                    'Processando...',
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

          if (_controller.pets.isEmpty) {
            return EmptyPetsToListView();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: _controller.pets.length,
            itemBuilder: (context, index) {
              final pet = _controller.pets[index];
              return DismissibleItem(pet, _controller);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const PetFormPage()),
          );
          _controller.getAllPets();
        },
        backgroundColor: const Color(0xFFF97316),
        elevation: 4,
        highlightElevation: 8,
        label: const Text(
          'Novo Pet',
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
