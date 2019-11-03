import 'package:flutter/material.dart';
import 'package:kaimarket/post/post_view_page.dart';
import 'package:kaimarket/styles/theme.dart';
import 'package:kaimarket/utils/base_height.dart';
import 'package:kaimarket/home/category_button.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:kaimarket/post/post_card.dart';
import 'package:kaimarket/models/category.dart';
import 'package:kaimarket/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaimarket/bloc/user_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kaimarket/models/post.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:throttling/throttling.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PostBloc _postBloc;
  UserBloc _userBloc;

  int selectedCategory = 0;

  //검색바
  TextEditingController searchController = TextEditingController();

  //무한 스크롤링 컨트롤러
  ScrollController scrollController = ScrollController();
  final Throttling thr = Throttling(duration: Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    _postBloc = BlocProvider.of<PostBloc>(context);
    _postBloc.add(PostFetch(reload: true));
    _userBloc = BlocProvider.of<UserBloc>(context);

    scrollController.addListener(_onInfiniteScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              SizedBox(
                  height: MediaQuery.of(context).padding.top), //상단 상태바 높이 띄우기
              _buildSearchInput(context),
              _buildCategoryList(context),
              SizedBox(height: screenAwareSize(10.0, context)),
              BlocBuilder(
                bloc: _postBloc,
                builder: (BuildContext context, PostState state) {
                  if (state is PostUninitialized) {
                    return Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: SpinKitChasingDots(
                                size: 30.0,
                                color: ThemeColor.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: screenAwareSize(50.0, context))
                        ],
                      ),
                    );
                  }
                  if (state is PostError) {
                    return Center(
                      child: Text('포스트를 불러오는데 실패했습니다.'),
                    );
                  }
                  if (state is PostLoaded) {
                    if (state.posts.isEmpty) {
                      return Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Center(child: Text("게시글이 없어요!")),
                            ),
                            SizedBox(height: screenAwareSize(50.0, context))
                          ],
                        ),
                      );
                    }
                    return Expanded(child: _buildSuggestions(context, state));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _onInfiniteScroll() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      thr.throttle(() {
        _postBloc.add(PostFetch(
            searchText: searchController.text,
            selectedCategory: selectedCategory));
      });
    }
  }

  Widget _buildSearchInput(context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: screenAwareSize(20.0, context),
        bottom: screenAwareSize(10.0, context),
      ),
      child: TextField(
        onSubmitted: (_) => _searchPosts(),
        controller: searchController,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () => _searchPosts(),
            child: Icon(Icons.search),
          ),
          hintText: "상품을 검색해보세요",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenAwareSize(15.0, context)),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.black.withOpacity(0.03),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
        ),
      ),
    );
  }

  void _searchPosts() {
    _postBloc.add(PostFetch(
        searchText: searchController.text,
        selectedCategory: selectedCategory,
        reload: true));
  }

  Widget _buildCategoryList(context) {
    return Container(
      height: screenAwareSize(70, context),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (context, idx) {
          return HomeCategoryButton(
            active: selectedCategory == idx,
            icon: CategoryList[idx].icon,
            text: CategoryList[idx].name,
            onPressed: () {
              setState(() {
                selectedCategory = idx;
                _postBloc.add(PostFetch(
                    selectedCategory: selectedCategory,
                    searchText: searchController.text,
                    reload: true));
              });
            },
          );
        },
        separatorBuilder: (context, idx) {
          return SizedBox(
            width: 10.0,
          );
        },
        itemCount: CategoryList.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildSuggestions(context, state) {
    return RefreshIndicator(
      displacement: 20.0,
      onRefresh: () async {
        _searchPosts();
      },
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        padding: EdgeInsets.only(bottom: screenAwareSize(50.0, context)),
        itemCount:
            state.bReachedMax ? state.posts.length + 1 : state.posts.length + 1,
        itemBuilder: (BuildContext context, int idx) {
          return idx == state.posts.length
              ? Container()
              : _buildRow(context, state.posts[idx]);
        },
        separatorBuilder: (BuildContext context, int i) {
          return Divider();
        },
      ),
    );
  }

  Widget _buildRow(context, Post post) {
    return PostCard(
        post: post,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostViewPage(postId: post.id)));
        },
        onTapHeart: () async {
          //서버 통신....
          var res = await dio.postUri(getUri('/api/posts/${post.id}/wish'));
          log.i(res.data);

          bool bWish = res.data['wish'];

          // _userBloc.add(UserChangeWish(postId: post.id));
          // post.isWish = !post.isWish;
          _postBloc.add(SearchWish(postId: post.id, wish: bWish));

          if (bWish) { 
            Fluttertoast.showToast(
              msg: "찜 목록에 추가하였습니다.",
              toastLength: Toast.LENGTH_SHORT,
              fontSize: screenAwareSize(10.0, context),
            );
          } else {
            Fluttertoast.showToast(
              msg: "찜 목록에서 제거하였습니다.",
              toastLength: Toast.LENGTH_SHORT,
              fontSize: screenAwareSize(10.0, context),
            );
          }
        });
  }
}
