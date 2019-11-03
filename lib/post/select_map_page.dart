import 'package:flutter/material.dart';
import 'package:kaimarket/post/google_map.dart';
import 'package:kaimarket/models/post.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kaimarket/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectMapPage extends StatefulWidget {
  final Post post;
  final bool edit;
  SelectMapPage({this.post, this.edit = false});

  @override
  State<StatefulWidget> createState() => SelectMapPageState();
}

class SelectMapPageState extends State<SelectMapPage> {
  LatLng defaultmarker;

  SelectMapPageState();

  GlobalKey<LoadingWrapperState> _loadingWrapperKey =
      GlobalKey<LoadingWrapperState>();

  @override
  void initState() {
    super.initState();
    log.i(widget.post);
    if (widget.edit) {
      setDefault();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: _loadingWrapperKey,
      builder: (context, loading) {
        return Stack(children: <Widget>[
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: Builder(
                builder: (context) {
                  return AppBar(
                    backgroundColor: Colors.white,
                    title: Text(
                      '선호 지역 선택',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    actions: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          onTap: () => _onTapComplete(context),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("완료"),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            body: GoogleMapPage(
              onTap: _onTapLagLng,
              defaultmarker: defaultmarker,
            ),
          ),
          loading
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: SpinKitChasingDots(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : Container()
        ]);
      },
    );
  }

  //지도에서 마커를 선택했을 시 좌표 값을 받아온다.
  _onTapLagLng(double lat, double lng) {
    log.i(widget.post);
    widget.post.locationLat = lat;
    widget.post.locationLng = lng;
  }

  //데이터 작성 완료
  _onTapComplete(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      if (widget.post.locationLat == null) {
        showSnackBar(context, "선호 지역을 선택해주세요.");
        return;
      }
      if (widget.edit) {
        log.i("edit");
        await dio.postUri(
          getUri('/api/posts/' + widget.post.id.toString()),
          data: {'data': widget.post.toJson()},
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        log.i("else");
        await dio.postUri(getUri('/api/posts'),
            data: {'data': widget.post.toJson()});

        Navigator.popUntil(context, ModalRoute.withName('/home'));
      }
      //데이터 새로 페치
      final postBloc = BlocProvider.of<PostBloc>(context);
      postBloc.add(PostFetch(reload: true));
    });
  }

  void setDefault() {
    if (widget.post.locationLat != null && widget.post.locationLng != null) {
      defaultmarker =
          new LatLng(widget.post.locationLat, widget.post.locationLng);
    }
  }
}
