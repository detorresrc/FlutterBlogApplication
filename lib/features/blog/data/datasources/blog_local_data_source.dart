import 'package:blog_app_clean_architecture/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocalDataSource {
  void uploadLocalBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadBlogs();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;
  const BlogLocalDataSourceImpl({required this.box});

  @override
  List<BlogModel> loadBlogs() {
    final List<BlogModel> blogs = [];

    box.read(() {
      for (int i = 0; i < box.length; i++) {
        blogs.add(
          BlogModel.fromJson(
            box.get(
              i.toString(),
            ),
          ),
        );
      }
    });

    return blogs;
  }

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    box.clear();

    box.write(() {
      for (int i = 0; i < blogs.length; i++) {
        box.put(i.toString(), blogs[i].toJson());
      }
    });
  }
}
