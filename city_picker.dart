import 'package:flutter/material.dart';
import 'cool_text.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'city_picker_api_config.dart';

class CityPicker extends StatefulWidget {
  final String hitText;

  const CityPicker({Key key, this.hitText}) : super(key: key);
  @override
  _CityPickerState createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  var dio = Dio();
  var host = CityPickerApiConfig.host;
  //搜索建议
  var suggestList = [];
  bool isSuggest = false;
  var suggestTextController = TextEditingController();
  bool dataLoadCompleted = false;
  //历史记录
  var hisList = ["北京", "上海", "深圳", "惠州"];
  //热门城市
  var hotList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    //获取热门城市，可以考虑缓存，因为这基本上不会变
    var strHot = await dio.get<String>("$host/api/CityPicker?sword=hot");
    hotList = json.decode(strHot.data);

    setState(() {
      dataLoadCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CoolText(
          widget.hitText ?? "城市选择",
          textColor: Colors.blue,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          color: Colors.black54,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return !dataLoadCompleted
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 8),
                  decoration: ShapeDecoration(
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]))),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      Expanded(
                          child: TextField(
                        controller: suggestTextController,
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty) {
                            onTextChange(value);
                          } else {
                            setState(() {
                              isSuggest = false;
                            });
                          }
                        },
                        decoration: InputDecoration(border: InputBorder.none),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      CustomScrollView(
                        slivers: [
                          //历史记录
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 16, 16, 16.0),
                              child: CoolText(
                                "历史记录",
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int position) {
                              return createItemWidget(position, 0);
                            }, childCount: hisList.length),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 2),
                          ),
                          //热门城市
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Divider(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 16, 16, 16.0),
                              child: CoolText(
                                "热门城市",
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int position) {
                              return createItemWidget(position, 1);
                            }, childCount: hotList.length),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 2),
                          )
                        ],
                      ),
                      //搜索建议
                      Offstage(
                        offstage: !isSuggest,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          color: Colors.grey[100],
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final cityname = suggestList[index]["name"];
                              return Container(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () =>
                                          Navigator.of(context).pop(cityname),
                                      dense: true,
                                      title: CoolText(
                                        cityname,
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            },
                            itemCount: suggestList.length,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }

  //type(0:历史搜索，1：热门城市)
  createItemWidget(int position, int type) {
    var cityname = "";
    if (type == 0) {
      cityname = hisList[position];
    } else {
      cityname = hotList[position]["name"];
    }
    final citystr = cityname;
    return InkWell(
      onTap: () => Navigator.of(context).pop(citystr),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: ShapeDecoration(
            shape: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$citystr",
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
  }

  //搜索建议
  Future<void> onTextChange(String value) async {
    dio.clear();
    if (value != null && value != "") {
      var strSuggest =
          await dio.get<String>("$host/api/CityPicker?sword=$value");
      suggestList = json.decode(strSuggest.data);
      setState(() {
        isSuggest = true;
      });
    }
  }
}
