part of 'display_bloc.dart';

enum DisplayStatus { initial, loading, loaded, error, uploading, uploaded }

class DisplayState extends Equatable {
  final List<Display> displayList;
  final List<File> screenShots;
  final DisplayStatus displayStatus;
  const DisplayState({
    this.displayList = const [],
    this.screenShots = const [],
    this.displayStatus = DisplayStatus.initial,
  });

  DisplayState copyWith({
    Display? primaryDisplay,
    List<Display>? displayList,
    List<File>? screenShots,
    DisplayStatus? displayStatus,
  }) {
    return DisplayState(
      displayList: displayList ?? this.displayList,
      screenShots: screenShots ?? this.screenShots,
      displayStatus: displayStatus ?? this.displayStatus,
    );
  }
  
  @override
  List<Object> get props => [
    displayList,
    screenShots,
    displayStatus,
  ];
}
