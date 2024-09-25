part of 'display_bloc.dart';

sealed class DisplayEvent extends Equatable {
  const DisplayEvent();

  @override
  List<Object> get props => [];
}

class AddDisplaysEvent extends DisplayEvent {
  @override
  List<Object> get props => [];
}

class LoadAcreenshotsEvent extends DisplayEvent {
  @override
  List<Object> get props => [];
}

class DeleteScreenshotsEvent extends DisplayEvent {
  @override
  List<Object> get props => [];
}

class TakeScreenshotEvent extends DisplayEvent {
  const TakeScreenshotEvent();

  @override
  List<Object> get props => [];
}
