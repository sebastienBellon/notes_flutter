import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(context, state),
        );
      },
    );
  }

  Stack _buildBody(BuildContext context, AuthState authState) {
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
            )
          ],
        ),
      ],
    );
  }
}
