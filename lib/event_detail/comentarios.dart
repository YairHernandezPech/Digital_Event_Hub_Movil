import 'dart:math';
import 'package:digital_event_hub/event_detail/api_cometarios.dart';
import 'package:digital_event_hub/sesion/login/idUser.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:digital_event_hub/widgets/cards/cardReview.dart';

void Comentarios(BuildContext context, TickerProvider vsync, int eventoId) {
  int userId = int.parse(UserSession().userId!);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    transitionAnimationController: AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(seconds: 1),
    ),
    builder: (BuildContext context) {
      return ComentariosSheet(eventoId: eventoId, userId: userId);
    },
  );
}

class ComentariosSheet extends StatefulWidget {
  final int eventoId;
  final int userId;

  ComentariosSheet({required this.eventoId, required this.userId});

  @override
  _ComentariosSheetState createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<ComentariosSheet> {
  late Future<List<Map<String, dynamic>>> commentsFuture;
  TextEditingController commentController = TextEditingController();
  ApiServiceComentarios apiService = ApiServiceComentarios();
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  List<Map<String, dynamic>> reviewsList = [];

  @override
  void initState() {
    super.initState();
    commentsFuture = loadComments(page: 1);
  }

  Future<List<Map<String, dynamic>>> loadComments({int page = 1}) async {
    if (isLoading || !hasMore) return reviewsList;
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> comments = await apiService.fetchComments(widget.eventoId, page: page, limit: 10);
      for (var comment in comments) {
        Map<String, dynamic> user = await apiService.fetchUser(comment['usuario_id']);
        reviewsList.add({
          'comentario_id': comment['comentario_id'],
          'usuario_id': comment['usuario_id'],
          'username': user['nombre'],
          'img': user['fotoPerfil'],
          'qualification': (Random().nextDouble() * 5).toStringAsFixed(1),
          'text': comment['comentario'],
          'fecha': comment['fecha'].substring(0, 10),
        });
      }

      if (comments.isEmpty) {
        setState(() {
          hasMore = false;
        });
      } else {
        setState(() {
          currentPage++;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
      throw e;
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return reviewsList;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 5, // Número arbitrario para mostrar las tarjetas de carga
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(height: 5.0),
                        ReviewCard(
                          '',
                          '',
                          '',
                          '',
                          '',
                        ),
                        SizedBox(height: 10.0),
                      ],
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Comentarios',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: reviewsList.length + (hasMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == reviewsList.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (hasMore) {
                                      loadComments(page: currentPage);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                  ),
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : Text(
                                          hasMore ? 'Cargar más' : 'No hay más comentarios',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                ),
                              ),
                            );
                          } else {
                            final comentario = reviewsList[index];
                            return Column(
                              children: [
                                SizedBox(height: 5.0),
                                Dismissible(
                                  key: Key(comentario['comentario_id'].toString()),
                                  direction: comentario['usuario_id'] == widget.userId
                                      ? DismissDirection.endToStart
                                      : DismissDirection.none,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: comentario['usuario_id'] == widget.userId
                                      ? (direction) async {
                                          try {
                                            await apiService.deleteComment(comentario['comentario_id']);
                                            setState(() {
                                              reviewsList.removeAt(index);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Comentario eliminado')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al eliminar comentario: $e')),
                                            );
                                          }
                                        }
                                      : null,
                                  child: ReviewCard(
                                    comentario['username'] ?? '',
                                    comentario['img'] ?? '',
                                    comentario['qualification'].toString(),
                                    comentario['text'] ?? '',
                                    comentario['fecha'] ?? '',
                                  ),
                                ),
                                SizedBox(height: 10.0),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    // Campo de texto para enviar un nuevo comentario
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Escribe algo...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              onPressed: () async {
                                if (commentController.text.isNotEmpty) {
                                  try {
                                    await apiService.createComment(
                                        widget.eventoId,
                                        widget.userId,
                                        commentController.text);
                                    // Recargar los comentarios después de enviar uno nuevo
                                    setState(() {
                                      commentsFuture = loadComments(page: 1);
                                      reviewsList.clear(); // Limpiar la lista para evitar duplicados
                                      hasMore = true;
                                      currentPage = 1;
                                    });
                                    commentController.clear();
                                  } catch (e) {
                                    print('Failed to post comment: $e');
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
