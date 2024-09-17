part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogFailure extends BlogState {
  final String message;
  BlogFailure(this.message);
}

final class BlogUploadSuccess extends BlogState {
  final Blog blog;
  BlogUploadSuccess({required this.blog});
}

final class BlogGetAllBlogsSuccess extends BlogState {
  final List<Blog> blogs;
  BlogGetAllBlogsSuccess({required this.blogs});
}
