import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaimarket/chat/chat_card.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:kaimarket/models/chat.dart';
import 'package:kaimarket/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaimarket/chat/chat_view_page.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChatLists();
  }
}

class ChatListsState extends State<ChatLists> {
  List<Chat> chats = [];

  UserBloc _userBloc;
  int loggedUserId = 0;

  @override
  void initState() {
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);
    final UserLoaded user = _userBloc.state;
    loggedUserId = user.id;
    fetchList();
  }

  Future fetchList() async {
    var res = await dio.getUri(getUri('/api/chats'));
    if (res.statusCode == 200) {
      if (mounted) {
        setState(() {
          chats = res.data
              .map((chat) {
                return Chat.fromJson(chat);
              })
              .toList()
              .cast<Chat>();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "채팅방 목록",
          style: TextStyle(fontSize: screenAwareSize(16.0, context)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('UserRooms').snapshots(),
        builder: (context,  snapshot) {
          if (snapshot.hasError) log.i(snapshot.error);
          if (!snapshot.hasData) return const Text('Loading..');
          log.i(snapshot.data);
          return ListView.separated(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: screenAwareSize(60.0, context)),
            itemBuilder: (context, i) {
              return ChatCard(
                chat: chats[i],
                loggedUserId: loggedUserId,
                onPressed: () {
                  setState(() {
                    chats[i].buyerNonReadCount = 0;
                    chats[i].sellerNonReadCount = 0;
                  });

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatViewPage(chatId: chats[i].id)));
                },
              );
            },
            itemCount: chats.length,
            separatorBuilder: (context, idx) {
              return Container(
                height: 1.0,
                width: double.infinity,
                color: Colors.grey[200],
              );
            },
          );
        },
      ),
    );
  }
}

class ChatLists extends StatefulWidget {
  @override
  ChatListsState createState() => ChatListsState();
}
