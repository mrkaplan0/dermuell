import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: constraints.maxWidth,
            //height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: XConst.getRandomColor(),
                  child: Text(
                    widget.message.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message.title,
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        widget.message.content,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                        maxLines: _isExpanded ? null : 3,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (widget.message.content.length > 100)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Text(
                              _isExpanded ? 'Show less' : 'Show more',
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${widget.message.willDeleteAt.difference(DateTime.now()).inHours} Std. übrig',
                            style: TextStyle(fontSize: 12),
                          ),
                          Spacer(),
                          Icon(
                            Icons.recycling,
                            size: 16,
                            color: XConst.sixthColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.message.recycleCount.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: XConst.secondaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.message.commentCount.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.message.deleteCount.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
