import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/queue_screen.dart';

class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/lyrics.png',color:Colors.white54, width: 22,),
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> QueueScreen()));
              },
              child: Icon(CupertinoIcons.bars, color: Colors.white, size: 30,)),
        ],
      ),
    );
  }
}
