import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:blog_app_clean_architecture/core/error/exceptions.dart';
import 'package:blog_app_clean_architecture/core/error/failures.dart';
import 'package:blog_app_clean_architecture/core/network/connection_checker.dart';
import 'package:blog_app_clean_architecture/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_app_clean_architecture/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_app_clean_architecture/features/blog/data/models/blog_model.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/entities/blog.dart';
import 'package:blog_app_clean_architecture/features/blog/domain/repositories/blog_repository.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;

  BlogRepositoryImpl({
    required this.blogRemoteDataSource,
    required this.blogLocalDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      BlogModel blog = BlogModel(
        id: const Uuid().v4().toString(),
        title: title,
        content: content,
        posterId: posterId,
        topics: topics,
        imageUrl: "",
        updatedAt: DateTime.now(),
      );

      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blog,
      );

      blog = blog.copyWith(imageUrl: imageUrl);

      final uploadedBlog = await blogRemoteDataSource.uploadBlog(blog);

      return Right(uploadedBlog);
    } on ServerException catch (e) {
      return Left(
        Failure(e.message),
      );
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return Right(
          blogLocalDataSource.loadBlogs(),
        );
      }

      final blogs = await blogRemoteDataSource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlogs(
        blogs: blogs,
      );
      return Right(blogs);
    } on ServerException catch (e) {
      return Left(
        Failure(e.message),
      );
    }
  }
}
