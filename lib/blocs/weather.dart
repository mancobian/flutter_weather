import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/models/models.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:meta/meta.dart';

// EVENTS //////////////////////////////////////////////////////////////////////

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class WeatherRequested extends WeatherEvent {
  final String city;

  const WeatherRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

class WeatherRefreshRequested extends WeatherEvent {
  final String city;

  const WeatherRefreshRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

// STATES //////////////////////////////////////////////////////////////////////

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Weather weather;

  const WeatherLoadSuccess({@required this.weather}) : assert(weather != null);

  @override
  List<Object> get props => [weather];
}

class WeatherLoadFailure extends WeatherState {}

// BLOC ////////////////////////////////////////////////////////////////////////

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository})
      : assert(weatherRepository != null),
        super(WeatherInitial());

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is WeatherRequested) {
      yield* this._mapWeatherRequestedToState(event);
    } else if (event is WeatherRefreshRequested) {
      yield* this._mapWeatherRefreshRequestedToState(event);
    }
  }

  Stream<WeatherState> _mapWeatherRequestedToState(
      WeatherRequested event) async* {
    yield WeatherLoadInProgress();
    try {
      final Weather weather = await weatherRepository.getWeather(event.city);
      yield WeatherLoadSuccess(weather: weather);
    } catch (_) {
      yield WeatherLoadFailure();
    }
  }

  Stream<WeatherState> _mapWeatherRefreshRequestedToState(
      WeatherRefreshRequested event) async* {
    try {
      final Weather weather = await weatherRepository.getWeather(event.city);
      yield WeatherLoadSuccess(weather: weather);
    } catch (_) {}
  }
}
