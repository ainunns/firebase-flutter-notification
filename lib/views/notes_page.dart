import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_notification/viewmodels/notes_viewmodel.dart';
import 'package:firebase_flutter_notification/models/note.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesViewModel(context.read(), context.read()),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text('Notes'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed:
                    viewModel.isLoading || viewModel.isProcessingNotification
                        ? null
                        : () => _showNoteDialog(context, viewModel),
                child: const Icon(Icons.add),
              ),
              body: StreamBuilder<List<Note>>(
                stream: viewModel.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final notes = snapshot.data!;
                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                          'No notes yet. Add one by clicking the + button.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        child: ListTile(
                          title: Text(note.text),
                          subtitle: Text(
                            'Created: ${note.createdAt.toLocal().toString().split('.')[0]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: viewModel.isLoading ||
                                        viewModel.isProcessingNotification
                                    ? null
                                    : () => _showNoteDialog(
                                          context,
                                          viewModel,
                                          docId: note.id,
                                          existingText: note.text,
                                        ),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit note',
                              ),
                              IconButton(
                                onPressed: viewModel.isLoading ||
                                        viewModel.isProcessingNotification
                                    ? null
                                    : () => _showDeleteConfirmation(
                                          context,
                                          viewModel,
                                          note.id,
                                        ),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete note',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (viewModel.isLoading || viewModel.isProcessingNotification)
              Container(
                color: Colors.black.withAlpha(77),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context,
    NotesViewModel viewModel, {
    String? docId,
    String? existingText,
  }) async {
    final controller = TextEditingController(text: existingText);
    final formKey = GlobalKey<FormState>();
    bool isProcessing = false;

    return showDialog(
      context: context,
      barrierDismissible: !isProcessing,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(docId == null ? 'Add Note' : 'Edit Note'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              enabled: !isProcessing,
              decoration: const InputDecoration(
                hintText: 'Enter your note here',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        setState(() => isProcessing = true);
                        final text = controller.text.trim();
                        try {
                          if (docId == null) {
                            await viewModel.addNote(text);
                          } else {
                            await viewModel.updateNote(docId, text);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isProcessing = false);
                          }
                        }
                      }
                    },
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(docId == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    NotesViewModel viewModel,
    String docId,
  ) async {
    bool isProcessing = false;

    return showDialog(
      context: context,
      barrierDismissible: !isProcessing,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      setState(() => isProcessing = true);
                      Navigator.pop(context);
                      try {
                        await viewModel.deleteNote(docId);
                      } finally {
                        if (context.mounted) {
                          setState(() => isProcessing = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
