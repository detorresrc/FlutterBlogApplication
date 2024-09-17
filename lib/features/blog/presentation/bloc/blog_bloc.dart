import 'dart:async';
import 'dart:io';

import 'package:blog_app_clean_architecture/core/usecase/usecase.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/entities/blog.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;

  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));

    on<BlogUploadEvent>(_onBlogUpload);

    on<BlogGetAllBlogsEvent>(_onGetAllBlogsEvent);
  }

  FutureOr<void> _onBlogUpload(
      BlogUploadEvent event, Emitter<BlogState> emit) async {
    final result = await _uploadBlog(UploadBlogParams(
      posterId: event.posterId,
      title: event.title,
      content: event.content,
      image: event.image,
      topics: event.topics,
    ));

    result.fold(
      (l) => emit(
        BlogFailure(l.message),
      ),
      (r) => emit(
        BlogUploadSuccess(blog: r),
      ),
    );
  }

  FutureOr<void> _onGetAllBlogsEvent(
      BlogGetAllBlogsEvent event, Emitter<BlogState> emit) async {
    final result = await _getAllBlogs(NoParams());
    result.fold(
      (l) => emit(
        BlogFailure(l.message),
      ),
      (r) => emit(
        BlogGetAllBlogsSuccess(blogs: r),
      ),
    );
  }
}
