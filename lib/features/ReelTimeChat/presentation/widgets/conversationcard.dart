import 'package:flutter/material.dart';

import '../../domain/entities/message.dart';

class ConversationCard
    extends StatelessWidget {

  final String contactId;
  final Message message;
  final bool unread;
  final String date;
  final VoidCallback onTap;

  const ConversationCard({
    required this.contactId,
    required this.message,
    required this.unread,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue
                .withOpacity(.04),
            blurRadius: 15,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(22),
        onTap: onTap,

        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [

              Stack(
                children: [

                  const CircleAvatar(
                    radius: 34,
                    backgroundImage:
                    AssetImage(
                      'assets/profile.png',
                    ),
                  ),

                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.green,
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color:
                          Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            contactId,
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF123B7A,
                              ),
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),

                        Text(
                          date,
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF7893BA,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            message.text,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF315B98,
                              ),
                              fontSize: 14.5,
                              height: 1.35,
                            ),
                          ),
                        ),

                        if (unread)
                          Container(
                            width: 32,
                            height: 32,
                            alignment:
                            Alignment.center,
                            decoration:
                            const BoxDecoration(
                              color:
                              Color(
                                0xFF1468F5,
                              ),
                              shape:
                              BoxShape.circle,
                            ),
                            child: Text(
                              '1',
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}