import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kaimarket/bloc/post_event.dart';
import 'package:kaimarket/models/chat.dart';
import 'package:kaimarket/post/google_map_fixed.dart';
import 'package:kaimarket/post/post_book_page.dart';
import 'package:kaimarket/post/post_card.dart';
import 'package:kaimarket/styles/theme.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:kaimarket/models/book.dart';
import 'dart:math' as math;
import 'package:kaimarket/models/post.dart';
import 'package:kaimarket/utils/dio.dart';
import 'package:kaimarket/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaimarket/post/post_shimmer_card.dart';
import 'package:kaimarket/chat/chat_view_page.dart';
import 'package:kaimarket/post/post_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostViewPage extends StatefulWidget {
  final int postId;

  PostViewPage({@required this.postId});

  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  static const double horizontalPadding = 16.0;

  Post post;
  List<Post> relatedPosts;
  ScrollController scrollController;
  GlobalKey<LoadingWrapperState> _loadingWrapperKey =
      GlobalKey<LoadingWrapperState>();

  UserBloc _userBloc;
  int loggedUserId = 0;

  @override
  void initState() {
    super.initState();

    initPost();

    scrollController = ScrollController();

    _userBloc = BlocProvider.of<UserBloc>(context);
    final UserLoaded user = _userBloc.state;
    loggedUserId = user.id;
  }

  void initPost() async {
    var res = await dio.getUri(getUri('/api/posts/${widget.postId}'));
    if (res.data == "") {
      _showDeleteDialog();
    }

    Post p = Post.fromJson(res.data);
    relatedPosts = res.data['relatedPosts']
        .map((p) {
          return Post.fromJson(p);
        })
        .toList()
        .cast<Post>();
    await Future.delayed(Duration(milliseconds: 250));

    if (res.statusCode == 200) {
      if (mounted) {
        setState(() {
          post = p;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) {
      return PostShimmerCard();
    }
    return LoadingWrapper(
      key: _loadingWrapperKey,
      builder: (context, loading) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  SafeArea(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildImageCarousel(),
                          SizedBox(height: screenAwareSize(10.0, context)),
                          post.isBook
                              ? _buildBookPostHeader(context)
                              : _buildPostHeader(context),
                          _buildDivider(),
                          _buildPostContent(context),
                          _buildLocation(),
                          _buildDivider(),
                          _buildUserInfo(context),
                          _buildDivider(),
                          _buildRelatedPosts(context),
                          SizedBox(height: screenAwareSize(70.0, context)),
                        ],
                      ),
                    ),
                  ),
                  _buildAppBar(),
                  loggedUserId == post.user.id
                      ? _buildSellerBottomTab()
                      : _buildBottomTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final double opacityTween = math.max(
            math.min(
                scrollController.offset / screenAwareSize(350.0, context), 1),
            0);
        return Container(
          height: screenAwareSize(50.0, context) +
              MediaQuery.of(context).padding.top,
          child: AppBar(
            title: Opacity(
                opacity: opacityTween,
                child: Text(
                  post.title,
                  style: TextStyle(fontSize: screenAwareSize(16.0, context)),
                )),
            backgroundColor: Colors.white.withOpacity(opacityTween),
            bottomOpacity: 0.0,
            elevation: opacityTween >= 1.0 ? 2.0 : 0.0,
          ),
        );
      },
    );
  }

  Widget _buildRelatedPosts(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenAwareSize(10.0, context)),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenAwareSize(16.0, context),
              vertical: screenAwareSize(5.0, context)),
          child: Text(
            "같은 카테고리 상품",
            style: TextStyle(
              fontSize: screenAwareSize(11.0, context),
              color: Colors.grey[500],
            ),
          ),
        ),
        SizedBox(height: screenAwareSize(15.0, context)),
        for (int i = 0; i < relatedPosts.length; i++)
          PostCard(
            post: relatedPosts[i],
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      PostViewPage(postId: relatedPosts[i].id)));
            },
          )
      ],
    );
  }

  Widget _buildSellerBottomTab() {
    var _status = ['판매중', '예약중', '판매완료'];
    var _currentStatus;
    if (post.status == 0)
      _currentStatus = '판매중';
    else if (post.status == 1)
      _currentStatus = '예약중';
    else if (post.status == 2) _currentStatus = '판매완료';

    return Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Container(
            height: screenAwareSize(50.0, context),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3.0,
                    spreadRadius: -3.0,
                    offset: Offset(0, -3)),
              ],
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: post.isBook
                          ? () {
                              Book book = new Book(
                                title: post.title,
                                image: post.bookImage,
                                author: post.bookAuthor,
                                price: post.bookPrice,
                                pubdate: post.bookPubDate,
                                publisher: post.bookPublisher,
                              );
                              return Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostBookPage(
                                    book: book,
                                    post: post,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostPage(post: post),
                                ),
                              );
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: screenAwareSize(14.0, context),
                          ),
                          SizedBox(width: screenAwareSize(7.0, context)),
                          Text('수정하기',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: screenAwareSize(14.0, context))),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("삭제하기"),
                                content: new Text("정말로 삭제하시겠습니까?"),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Yes"),
                                    onPressed: () async {
                                      final postBloc =
                                          BlocProvider.of<PostBloc>(context);
                                      log.i(post.id);
                                      postBloc.add(PostDelete(postId: post.id));
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.remove,
                            color: Colors.grey,
                            size: screenAwareSize(14.5, context),
                          ),
                          SizedBox(width: screenAwareSize(7.0, context)),
                          Text('삭제하기',
                              style: TextStyle(
                                  fontSize: screenAwareSize(14.0, context), color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      buttonColor: Colors.amber,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: _status.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (String newValueSelected) {
                            setState(() {
                              int val;
                              if (newValueSelected == '판매중')
                                val = 0;
                              else if (newValueSelected == '예약중')
                                val = 1;
                              else if (newValueSelected == '판매완료') val = 2;
                              post.status = val;
                              _currentStatus = newValueSelected;
                            });

                            final postBloc = BlocProvider.of<PostBloc>(context);
                            postBloc.add(StatusUpdate(
                                postId: post.id, status: post.status));
                          },
                          value: _currentStatus,
                          isExpanded: true,
                          style: TextStyle(fontSize: screenAwareSize(14.0, context), color: Colors.grey),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ),
                ])));
  }

  Widget _buildBottomTab() {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        height: screenAwareSize(50.0, context),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
                spreadRadius: -3.0,
                offset: Offset(0, -3.0)),
          ],
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () async {
                        //서버 통신....
                        var res = await dio
                            .postUri(getUri('/api/posts/${post.id}/wish'));

                        bool bWish = res.data['wish'];

                        final _postBloc = BlocProvider.of<PostBloc>(context);
                        _postBloc.add(SearchWish(postId: post.id, wish: bWish));
                        setState(() {
                          post.isWish = bWish;
                        });
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
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                          screenAwareSize(5.0, context),
                        ),
                        child: post.isWish
                            ? Icon(
                                Icons.favorite,
                                color: Colors.amber[200],
                              )
                            : Icon(Icons.favorite_border,
                                color: Colors.amber[200]),
                      )),
                  SizedBox(width: 5.0),
                  Text('찜', style: TextStyle(color: ThemeColor.primary)),
                ],
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(
                    vertical: screenAwareSize(10.0, context)),
                color: ThemeColor.primary,
                textColor: Colors.white,
                splashColor: Theme.of(context).primaryColorLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPressed:
                    loggedUserId == post.user.id ? null : _onPressChatSeller,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 60.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: screenAwareSize(14.0, context),
                      ),
                      SizedBox(width: 10.0),
                      Text('채팅으로 연락하기', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onPressChatSeller() {
    _loadingWrapperKey.currentState.loadFuture(() async {
      //채팅방을 생성한다.
      await Firestore.instance
          .collection("UserRooms")
          .document(post.user.id.toString())
          .setData({});

      await Firestore.instance
          .collection("UserRooms")
          .document(loggedUserId.toString())
          .setData({});

      // var res = await dio.postUri(getUri('/api/chats'), data: {
      //   'postId': post.id,
      //   'sellerId': post.user.id,
      // });

      // if (res.statusCode == 200) {
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => ChatViewPage(chatId: res.data)));
      // }
    });
  }

  List<CachedNetworkImage> _getImages() {
    List<CachedNetworkImage> images = List<CachedNetworkImage>();
    for (int i = 0; i < post.images.length; i++) {
      images.add(
        CachedNetworkImage(
          imageUrl: post.images[i]['url'],
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[200],
            highlightColor: Colors.grey[300],
            child: Container(
              width: double.infinity,
              height: screenAwareSize(350.0, context),
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return images;
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: <Widget>[
        Container(
          height: screenAwareSize(350.0, context),
          child: Carousel(
            autoplay: false,
            boxFit: BoxFit.cover,
            images: _getImages(),
            dotSize: 6.0,
            dotSpacing: 12.0,
            dotIncreaseSize: 1.6,
            dotIncreasedColor: Colors.amber[200],
            dotColor: Colors.amber[100],
            indicatorBgPadding: 10.0,
            dotBgColor: Colors.transparent,
            animationCurve: Curves.fastOutSlowIn,
            animationDuration: Duration(microseconds: 2000),
          ),
        ),
        if (post.isSold)
          Container(
              height: screenAwareSize(350.0, context),
              decoration:
                  new BoxDecoration(color: Color.fromARGB(140, 0, 0, 0)),
              child: Center(
                child: Text(
                  "SOLD\nOUT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenAwareSize(60.0, context),
                    color: ThemeColor.primary,
                    letterSpacing: 10.0,
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildBookPostHeader(context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenAwareSize(10.0, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  getMoneyFormat(post.price) + " 원",
                  style: TextStyle(
                    fontSize: screenAwareSize(18.0, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: screenAwareSize(5.0, context)),
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: screenAwareSize(
                      screenAwareSize(14.0, context),
                      context,
                    ),
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: screenAwareSize(10.0, context)),
                // Text(
                //   "Aasdas",
                //   style: TextStyle(
                //     fontSize: screenAwareSize(
                //       14.0,
                //       context,
                //     ),
                //     color: Colors.grey[800],
                //   ),
                // ),
                // SizedBox(height: screenAwareSize(10.0, context)),
                Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.clock,
                      size: screenAwareSize(12.0, context),
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      post.updatedAt,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: screenAwareSize(12.0, context),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Icon(
                      FontAwesomeIcons.eye,
                      size: screenAwareSize(12.0, context),
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 3.0),
                    Text(
                      post.view.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: screenAwareSize(12.0, context),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Icon(
                      FontAwesomeIcons.heart,
                      size: screenAwareSize(12.0, context),
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 3.0),
                    Text(
                      post.wish.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: screenAwareSize(12.0, context),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        CachedNetworkImage(
          imageUrl: post.bookImage,
          width: screenAwareSize(100.0, context),
          height: screenAwareSize(90.0, context),
          fit: BoxFit.cover,
        ),
        SizedBox(
          width: screenAwareSize(7, context),
        )
      ],
    );
  }

  Widget _buildPostHeader(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Text(
              getMoneyFormat(post.price) + " 원",
              style: TextStyle(
                fontSize: screenAwareSize(18.0, context),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(width: screenAwareSize(5.0, context)),
            if (post.status == 1)
              // if (post.isSold)
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: Container(
                    width: screenAwareSize(50.0, context),
                    height: screenAwareSize(20.0, context),
                    color: Colors.amber[800],
                    child: Center(
                      child: Text(
                        "예약중",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenAwareSize(10.0, context),
                            color: Colors.white),
                      ),
                    )),
              )
            else if (post.status == 2)
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: Container(
                    width: screenAwareSize(50.0, context),
                    height: screenAwareSize(20.0, context),
                    color: Colors.red[700],
                    child: Center(
                      child: Text(
                        "판매완료",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenAwareSize(10.0, context),
                            color: Colors.white),
                      ),
                    )),
              ),
          ]),
          SizedBox(height: screenAwareSize(5.0, context)),
          Text(
            post.title,
            style: TextStyle(
              fontSize: screenAwareSize(
                14.0,
                context,
              ),
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: screenAwareSize(10.0, context)),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.clock,
                size: screenAwareSize(12.0, context),
                color: Colors.grey[400],
              ),
              SizedBox(width: screenAwareSize(3.0, context)),
              Text(
                post.updatedAt,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: screenAwareSize(12.0, context),
                ),
              ),
              SizedBox(width: screenAwareSize(20.0, context)),
              Icon(
                FontAwesomeIcons.eye,
                size: screenAwareSize(12.0, context),
                color: Colors.grey[400],
              ),
              SizedBox(width: screenAwareSize(3.0, context)),
              Text(
                post.view.toString(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: screenAwareSize(12.0, context),
                ),
              ),
              SizedBox(width: screenAwareSize(20.0, context)),
              Icon(
                FontAwesomeIcons.heart,
                size: screenAwareSize(12.0, context),
                color: Colors.grey[400],
              ),
              SizedBox(width: screenAwareSize(3.0, context)),
              Text(
                post.wish.toString(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: screenAwareSize(12.0, context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPostContent(context) {
    final myController = TextEditingController();

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "상품설명",
                style: TextStyle(
                  fontSize: screenAwareSize(11.0, context),
                  color: Colors.grey[500],
                ),
              ),
              GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    screenAwareSize(32.0, context)))),
                            contentPadding: EdgeInsets.only(
                                top: screenAwareSize(20.0, context)),
                            content: Container(
                              width: 300.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "신고하기",
                                        style: TextStyle(
                                            fontSize:
                                                screenAwareSize(16.0, context),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: screenAwareSize(15.0, context),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    height: 4.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: TextField(
                                      controller: myController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: "신고 내용을 적어주세요.",
                                        border: InputBorder.none,
                                      ),
                                      maxLines: 8,
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    height: 4.0,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await dio.postUri(
                                          getUri(
                                              '/api/posts/${post.id}/report/'),
                                          data: {"content": myController.text});
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenAwareSize(20.0, context),
                                          bottom:
                                              screenAwareSize(20.0, context)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                                screenAwareSize(32.0, context)),
                                            bottomRight: Radius.circular(
                                                screenAwareSize(
                                                    32.0, context))),
                                      ),
                                      child: Text(
                                        "제출하기",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  //   showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return CupertinoAlertDialog(
                  //         title: Text('신고하기'),
                  //         content: TextFormField(),
                  //         actions: <Widget>[
                  //           FlatButton(
                  //               onPressed: () {
                  //                 Navigator.pop(context);
                  //               },
                  //               child: Text('Close')),
                  //           FlatButton(
                  //             onPressed: () {
                  //               print('제출하기!');
                  //               Navigator.pop(context);
                  //             },
                  //             child: Text('제출하기'),
                  //           )
                  //         ],
                  //       );
                  //     },
                  //   );
                  // },
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: screenAwareSize(13.0, context),
                        ),
                        SizedBox(width: screenAwareSize(3.0, context)),
                        Text(
                          "신고하기",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: screenAwareSize(11.0, context),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          SizedBox(height: screenAwareSize(15.0, context)),
          Text(post.content, style: TextStyle(fontSize: screenAwareSize(11.0, context), height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: screenAwareSize(10.0, context)),
    );
  }

  Widget _buildUserInfo(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(5.0, context)),
      child: Container(
        height: screenAwareSize(50.0, context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: screenAwareSize(50.0, context),
              height: screenAwareSize(50.0, context),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400], width: 1.0),
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image:
                      ExactAssetImage(getRandomAvatarUrlByPostId(post.user.id)),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.user.name,
                  style: TextStyle(
                    fontSize: screenAwareSize(14.0, context),
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "판매내역 : " + post.user.salesCount.toString() + "개",
                  style: TextStyle(
                    fontSize: screenAwareSize(10.0, context),
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("접근"),
          content: new Text("삭제된 게시물입니다."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenAwareSize(10.0, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '거래 선호 위치',
            style: TextStyle(
              fontSize: screenAwareSize(11.0, context),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: screenAwareSize(10.0, context)),
          GoogleMapfixed(
            picked: LatLng(
              post.locationLat,
              post.locationLng,
            ),
          )
        ],
      ),
    );
  }
}
