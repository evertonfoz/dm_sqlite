import 'package:flutter/material.dart';
import 'package:pet_care/core/presentation/widgets/app_drawer.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/tutor/data/datasources/tutor_local_datasource.dart';
import 'package:pet_care/features/tutor/data/datasources/tutor_remote_datasource.dart';
import 'package:pet_care/features/tutor/data/repositories/tutor_repository.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_form_page.dart';
import 'package:pet_care/features/tutor/data/repositories/sync_tutor_repository_impl.dart';

import '../../../pet/data/repositories/sqlite_pet_repository.dart';
import '../widgets/list/empty_tutors.dart';
import '../widgets/list/tutor_dismissible_item.dart';

class TutorListPage extends StatefulWidget {
  final TutorController? controller;
  final AuthController? authController;
  const TutorListPage({super.key, this.controller, this.authController});

  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  late final TutorController _controller;
  late final ScrollController _scrollController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
    _controller = widget.controller ?? TutorController(
      TutorRepositoryImpl(SupabaseTutorRemoteDataSource()),
      SqlitePetRepository(SqflitePetLocalDataSource()),
      SyncTutorRepositoryImpl(
        remoteDataSource: SupabaseTutorRemoteDataSource(),
        localDataSource: SqfliteTutorLocalDataSourceImpl(),
      ),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _controller.loadFirstPage();
    // Inicia a sincronização de forma silenciosa ou mostrando o ícone de load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.syncData();
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0;

    if (maxScroll > 0 && (maxScroll - currentScroll) <= delta) {
      _controller.loadNextPage();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _scrollController.dispose();
    if (widget.authController == null) {
      _authController.dispose();
    }
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
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isSyncing) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                      ),
                    ),
                  ),
                );
              }
              return IconButton(
                onPressed: _controller.syncData,
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF0F766E)),
                tooltip: 'Sincronizar',
              );
            },
          ),
          IconButton(
            onPressed: _controller.getAllTutors,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F766E)),
            tooltip: 'Atualizar Lista',
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair da sua conta?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _authController.signOut();
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF0F766E)),
            tooltip: 'Sair da Conta',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(activeRoute: 'tutors', authController: _authController),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
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

          // +1 garante que o slot do rodapé sempre existe no ListView,
          // permitindo exibir tanto o spinner quanto a mensagem final.
          final itemCount = _controller.tutors.length + 1;

          return RefreshIndicator(
            onRefresh: _controller.getAllTutors,
            color: const Color(0xFF0F766E),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == _controller.tutors.length) {
                  // Rodapé: spinner durante paginação
                  if (_controller.isPaginating) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    );
                  }
                  // Rodapé: mensagem ao atingir o fim da lista
                  if (!_controller.hasMoreData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Center(
                        child: Text(
                          'Todos os tutores foram carregados.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  // Rodapé: espaço invisível quando há mais dados mas não está paginando
                  return const SizedBox(height: 80);
                }
                final tutor = _controller.tutors[index];
                return TutorDismissibleItem(tutor, _controller);
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // FloatingActionButton.extended(
          //   heroTag: 'generate_tutors_fab',
          //   onPressed: () async {
          //     await _controller.loadNextPage();
          //   },
          //   backgroundColor: const Color(0xFF0F766E),
          //   elevation: 4,
          //   label: const Text(
          //     'Carregar mais dados',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.bold,
          //       fontSize: 15,
          //     ),
          //   ),
          //   icon: const Icon(Icons.shuffle_rounded, color: Colors.white),
          // ),
          // const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'new_tutor_fab',
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
        ],
      ),
    );
  }
}
