import 'package:flutter/material.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ValidPage extends StatefulWidget {
  @override
  _ValidPageState createState() => _ValidPageState();
}

class _ValidPageState extends State<ValidPage> {
  TextEditingController idController;
  TextEditingController passwordController;

  GlobalKey<LoadingWrapperState> _loadingWrapperKey =
      GlobalKey<LoadingWrapperState>();

  @override
  void initState() {
    super.initState();

    idController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: _loadingWrapperKey,
      builder: (context, loading) {
        return Stack(
          children: <Widget>[
            Scaffold(
              body: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenAwareSize(16.0, context),
                        vertical: screenAwareSize(16.0, context)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(
                                  screenAwareSize(16.0, context)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/kaist_logo.png',
                                    width: screenAwareSize(100.0, context),
                                  ),
                                  SizedBox(
                                      height: screenAwareSize(20.0, context)),
                                  Text("카이스트 인증하기",
                                      style: TextStyle(
                                        fontSize:
                                            screenAwareSize(18.0, context),
                                        fontWeight: FontWeight.bold,
                                      )),
                                  SizedBox(
                                      height: screenAwareSize(20.0, context)),
                                  _buildTextFields(),
                                  SizedBox(
                                      height: screenAwareSize(20.0, context)),
                                  RaisedButton(
                                    onPressed: () {
                                      _validUser(context);
                                    },
                                    child: Text('인증'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
          ],
        );
      },
    );
  }

  _validUser(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      String id = idController.text;
      String password = passwordController.text;

      var res = await dio.postUri(getUri('/api/auth/valid'),
          data: {'id': id, 'password': password});
      if (res.statusCode == 200) {
        if (res.data) {
          //학번 인증 성공
          Navigator.of(context).pushReplacementNamed('/home');
          Fluttertoast.showToast(
            msg: "인증이 완료되었습니다.",
            toastLength: Toast.LENGTH_SHORT,
            fontSize: screenAwareSize(10.0, context),
          );
        } else {
          showSnackBar(context, "학번 인증에 실패했습니다. 다시 시도해주세요.");
        }
      }
    },
    onError: (e){
      showSnackBar(context, "이미 인증한 학번입니다.");
    });
  }

  Widget _buildTextFields() {
    return Column(
      children: <Widget>[
        TextField(
          controller: idController,
          decoration: InputDecoration(
            hintText: "아이디를 입력하세요",
          ),
        ),
        SizedBox(height: screenAwareSize(10.0, context)),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "비밀번호를 입력하세요",
          ),
          obscureText: true,
        ),
      ],
    );
  }
}
