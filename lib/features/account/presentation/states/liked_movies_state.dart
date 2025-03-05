part of '../cubit/liked_movies_cubit.dart';

sealed class LikedMoviesState extends Equatable {
  const LikedMoviesState();

  @override
  List<Object> get props => [];
}

final class LikedMoviesInitial extends LikedMoviesState {}
