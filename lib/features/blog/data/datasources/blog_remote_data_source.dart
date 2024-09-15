import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:blog_app_clean_architecture/core/error/exceptions.dart';
import 'package:blog_app_clean_architecture/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String _bucketName = "blog_images";

  BlogRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final insertedBlog =
          await supabaseClient.from("blogs").insert(blog.toJson()).select();

      return BlogModel.fromJson(insertedBlog.first);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage(
      {required File image, required BlogModel blog}) async {
    try {
      final extension = path.extension(image.path);
      final filePath = "blogs/${blog.id}$extension";

      await supabaseClient.storage.from(_bucketName).upload(
            filePath,
            image,
          );

      return supabaseClient.storage.from(_bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
