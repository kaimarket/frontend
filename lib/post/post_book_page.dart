import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaimarket/post/select_map_page.dart';
import 'package:kaimarket/utils/base_height.dart';
import 'package:kaimarket/post/photo_button.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:kaimarket/models/book.dart';
import 'package:kaimarket/post/post_book_card.dart';
import 'package:kaimarket/post/select_map_page.dart';
import 'package:kaimarket/models/post.dart';
import 'package:dio/dio.dart';

class PostBookPage extends StatefulWidget {
  final Book book;
  Post post;
  PostBookPage({@required this.book, this.post});

  @override
  State<StatefulWidget> createState() => PostBookPageState();
}

class PostBookPageState extends State<PostBookPage> {
  PostBookPageState();

  bool edit = false;

  TextEditingController priceController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  List<Map<String, dynamic>> imageUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      setDefault();
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    majorController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Builder(
          builder: (context) => _buildAppBar(context),
        ),
      ),
      body: Builder(builder: (context) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: _buildTotal(context),
            ),
            _buildBottomTabs(context),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "도서 판매하기",
        style: TextStyle(fontSize: 16.0),
      ),
      actions: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: () => _onTapNextPage(context),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("다음"),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapNextPage(context) {
    if (priceController.text == '') {
      showSnackBar(context, "희망가격을 입력해주세요.");
      return;
    }
    if (majorController.text == '') {
      showSnackBar(context, "수업명을 입력해주세요.");
      return;
    }
    if (contentController.text == '') {
      showSnackBar(context, "내용을 입력해주세요.");
      return;
    }
    if (imageUrls.length == 0) {
      showSnackBar(context, "상품의 이미지를 올려주세요.");
      return;
    }

    //포스트를 만들어 전달한다.
    // if (widget.post == null) widget.post = Post.fromBook(widget.book);
    // widget.post.price = int.parse(priceController.text);
    // widget.post.content = contentController.text;
    // widget.post.bookMajor = majorController.text;
    // widget.post.images = imageUrls;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMapPage(
          post: widget.post ?? Post.fromBook(widget.book)
            ..price = int.parse(priceController.text)
            ..content = contentController.text
            ..bookMajor = majorController.text
            ..images = imageUrls,
          edit: edit,
        ),
      ),
    );
  }

  Widget _buildTotal(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: screenAwareSize(5.0, context)),
          _buildBookInfo(context),
          _buildDivider(context),
          _buildPriceInput(context),
          _buildDivider(context),
          _buildMajorInput(context),
          _buildDivider(context),
          Container(
            child: Column(
              children: <Widget>[
                imageUrls.length > 0 ? _buildPhotoList(context) : Container(),
                _buildContentInput(context),
              ],
            ),
          ),
          SizedBox(height: screenAwareSize(50.0, context))
        ],
      ),
    );
  }

  Widget _buildBookInfo(context) {
    return Column(
      children: <Widget>[
        PostBookCard(
          book: widget.book,
        ),
      ],
    );
  }

  Widget _buildDivider(context) {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],
    );
  }

  Widget _buildPriceInput(context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenAwareSize(10.0, context),
            vertical: screenAwareSize(5.0, context)),
        child: TextField(
          controller: priceController,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "희망가격",
            hintStyle: TextStyle(
              fontSize: 14.0,
            ),
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  Widget _buildMajorInput(context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenAwareSize(10.0, context),
            vertical: screenAwareSize(5.0, context)),
        child: TextField(
          controller: majorController,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: "사용한 수업명",
            hintStyle: TextStyle(
              fontSize: 14.0,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildContentInput(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenAwareSize(10.0, context),
          vertical: screenAwareSize(5.0, context)),
      child: TextField(
        controller: contentController,
        maxLines: 10,
        decoration: InputDecoration(
          hintText:
              "책 상태를 자세하게 입력해주세요.\n예시)\n구입날짜: 2019년 01월 01일\n상태:필기흔적없음, 깨끗함",
          hintStyle: TextStyle(
            fontSize: 14.0,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPhotoList(context) {
    return Container(
      height: screenAwareSize(70, context),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(screenAwareSize(10.0, context)),
        itemBuilder: (context, idx) {
          return PhotoButton(
            url: imageUrls[idx]['thumb'],
            onPressed: () {
              setState(() {
                imageUrls.removeAt(idx);
              });
            },
          );
        },
        separatorBuilder: (context, idx) {
          return SizedBox(
            width: 10.0,
          );
        },
        itemCount: imageUrls.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildBottomTabs(context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0,
      child: Container(
        width: double.infinity,
        height: screenAwareSize(50.0, context),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Colors.black12,
          )
        ]),
        child: Row(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkResponse(
                containedInkWell: true,
                onTap: _uploadImages,
                radius: 10.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenAwareSize(15.0, context),
                    vertical: screenAwareSize(15.0, context),
                  ),
                  child: Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //이미지를 서버에 업로드하고 url과 썸네일을 받아온다.
  _uploadImages() async {
    List<Asset> images = await MultiImagePicker.pickImages(
      maxImages: 10,
      enableCamera: true,
    );

    //서버 업로드
    try {
      var imageData = await Future.wait(images.map((image) async {
        var bytes = await image.requestOriginal();
        FormData formData = FormData.from({
          'image':
              UploadFileInfo.fromBytes(bytes.buffer.asUint8List(), image.name)
        });

        var res = await dio.postUri(getUri('/api/upload'), data: formData);
        return res.data;
      }).toList());

      setState(() {
        imageUrls = imageUrls +
            imageData.map((json) {
              return {
                'thumb': json['thumb'].toString(),
                'url': json['url'].toString(),
              };
            }).toList();
      });
    } catch (e) {
      log.e(e);
    }
  }

  void setDefault() {
    priceController.text = widget.post.bookPrice.toString();
    majorController.text = widget.post.bookMajor;
    contentController.text = widget.post.content;
    imageUrls = widget.post.images;
    edit = true;
  }
}
