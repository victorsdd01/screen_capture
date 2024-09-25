
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:screenshot_playground/bloc/display_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ScreenListener {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenRetriever.addListener(this);
    context.read<DisplayBloc>().add(AddDisplaysEvent());
  }

  @override
  void dispose() {
    screenRetriever.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: BlocBuilder<DisplayBloc, DisplayState>(
          buildWhen: (previous, current) => previous.screenShots != current.screenShots || previous.displayList != current.displayList || previous.displayStatus != current.displayStatus,
          builder: (context, state) {
            return Column(
                  children: [
                    Text('Displays connected :${state.displayList.length}'),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                      child: const Text('Capture Screens'),
                      onPressed: () {
                        context.read<DisplayBloc>().add(const TakeScreenshotEvent());
                      },
                    ),
                    const SizedBox(height: 10,),
                    Expanded(
                      child: 
                      state.displayStatus == DisplayStatus.uploading ? const Column(
                        children: [
                            Text('Uploading Screenshots...'),
                           Center(child: CircularProgressIndicator(),),
                        ],
                      ) :
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: GridView.builder(
                            itemCount: state.screenShots.length,
                            itemBuilder: (context, index) {
                              
                              final screenshot = state.screenShots[index];
                              return Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  image: DecorationImage(
                                    image: FileImage(screenshot),
                                    fit: BoxFit.contain,
                                  )
                                ),
                              );
                            }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                          ),
                        ),
                    )
                  ],
                );
          },
        ),
      ),
    );
  }

  @override
  void onScreenEvent(String eventName) {
    context.read<DisplayBloc>().add(AddDisplaysEvent());
  }
}