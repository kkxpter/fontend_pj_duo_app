
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _GetXPageState extends StatefulWidget {
  const _GetXPageState({super.key});

  @override
  State<_GetXPageState> createState() => __GetXPageStateState();
}

class __GetXPageStateState extends State<_GetXPageState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
        children: [
          FilledButton(
            onPressed: (){
            Get.snackbar('แจ้งเตือน', 'โดนบิดละะ');
            }, child: const Text('Snack Bar')),
          FilledButton(
            onPressed: (){
              Get.defaultDialog(
                content: const Column(
                  children: [Text('หวยออก'),Text('ปิด')],
                ),
                actions: [
                  TextButton(onPressed: (){}, child: Text('ปิด')),
                  FilledButton(onPressed: (){}, child: const Text('รู้แล้ว'))
                ]
              );
              }, child: const Text('Default Dialog'),
              ),
        ]),
      ),
    );
  }
}