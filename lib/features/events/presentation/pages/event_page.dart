import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_admin/core/strings/app_strings.dart';
import 'package:web_admin/features/events/presentation/state/event_bloc.dart';
import 'package:web_admin/features/events/presentation/state/event_logs_bloc.dart';
import 'package:web_admin/features/events/presentation/state/event_logs_states.dart';
import 'package:web_admin/features/events/presentation/state/event_states.dart';
import 'package:web_admin/features/events/presentation/widgets/event_users_list.dart';
import 'package:web_admin/features/events/presentation/widgets/logs_panel.dart';
import 'package:web_admin/shared/widgets/app_bar.dart';

class EventPage extends StatelessWidget {
  final int eventId;
  const EventPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BlocBuilder<EventBloc, EventState>(builder: (context, state) {
            final provider = BlocProvider.of<EventBloc>(context);

            if(state is EventInitialState){
              provider.searchEvent(eventId);
            }
            if (state is EventUsersInvitedState || state is EventUserInvitedState){
              String phrase = switch(state){
                EventUsersInvitedState s => '${s.nInvited} ${AppStrings.nUsersInvited}',
                EventUserInvitedState s => '${s.email} ${AppStrings.hasBeenInvited}',
                EventState() => '',
              };
              Future.microtask(() {
                showDialog(
                  context: context,
                  builder: (subContext) {
                    return AlertDialog(
                      content: Text(phrase),
                    );
                  }
                );
              });
            }
            return switch(state){
              SearchingEventState _ => const CircularProgressIndicator(),
              EventUsersRetrievedState s => EventUsersList(users: s.users, eventId: eventId,),
              EventUsersInvitedState s => EventUsersList(users: s.users, eventId: eventId,),
              EventUserInvitedState s => EventUsersList(users: s.users, eventId: eventId,),
              EventFailureState _ => const Text(AppStrings.errorRetrievingUsers),
              EventState _ => const CircularProgressIndicator(),
            };
          }),
          BlocBuilder<EventLogsBloc, EventLogsState>(builder:(context, state){
            final provider = BlocProvider.of<EventLogsBloc>(context);
            if(state is EventLogsInitialState){
              provider.searchLogs(eventId);
            }
            return switch(state){
              EventLogsRetrieving _ => const CircularProgressIndicator(),
              EventLogsRetrievedState s => LogsPanel(logs: s.logs),
              EventLogsNewLog s=> LogsPanel(logs: s.logs),
              EventLogsState _ =>  const CircularProgressIndicator(),
            };
          })
        ],
      )
    );
  }
}
