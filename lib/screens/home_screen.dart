import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // BlocConsumer is used here since we want to fetch notes
    // when user is authenticated only -> call to method listener
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        context.read<NotesBloc>().add(FetchNotes());
      },
      builder: (context, authState) {
        return Scaffold(
          body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, notesState) {
              return _buildBody(context, authState, notesState);
            },
          ),
        );
      },
    );
  }

  Stack _buildBody(
      BuildContext context, AuthState authState, NotesState notesState) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text('Your Notes'),
              ),
              leading: IconButton(
                onPressed: () => authState is Authenticated
                    ? context.read<AuthBloc>().add(Logout())
                    : print('Go to Login'),
                icon: authState is Authenticated
                    ? const Icon(Icons.exit_to_app)
                    : const Icon(Icons.account_circle),
                iconSize: 28.0,
              ),
              actions: [
                IconButton(
                  onPressed: () => print('Changed theme'),
                  icon: const Icon(Icons.brightness_4),
                ),
              ],
            ),
            notesState is NotesLoaded
                ? NotesGrid(
                    onTap: (note) => print(note),
                    notes: notesState.notes,
                  )
                : const SliverPadding(padding: EdgeInsets.zero),
          ],
        ),
        notesState is NotesLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const SizedBox.shrink(),
        notesState is NotesError
            ? const Center(
                child: Text(
                  'Something went wrong!\nPlease check your connection.',
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
