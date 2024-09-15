import 'package:blog_app_clean_architecture/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Application'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AddNewBlogPage.route(),
              );
            },
            icon: const Icon(CupertinoIcons.add_circled),
          )
        ],
      ),
      body: const Center(
        child: Text('Blog Page'),
      ),
    );
  }

  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
}
