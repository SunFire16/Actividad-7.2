import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final _streamController = StreamController<List<String>>();
  List<String> messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    socket = IO.io('https://my-socket-server.vercel.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('connected');
    });
    socket.on('receive_message', (message) {
      messages.add(message);
      _streamController.add(messages);
    });
    socket.on('disconnect', (_) {});
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      socket.emit('send_message', _textController.text);
      messages.add(_textController.text);
      _streamController.add(messages);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket IO Chat'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay mensajes'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: snapshot.data![index].contains('Este mensaje lo reenvio el servidor')
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: snapshot.data![index].contains('Este mensaje lo reenvio el servidor')
                              ? Colors.grey.shade200
                              : Colors.blue[200],
                        ),
                        child: Text(
                          snapshot.data![index],
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
