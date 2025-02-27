import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import '../../constant/colors.dart';
import '../../service/noti.dart';
import '../../providers/user.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'customer_view.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late User dbUser;
  List userLst = [];
  double totalBalance = 0;
  DateTime nows = new DateTime.now();
  DateTime today = DateTime.now();
  DateTime selectedFromDate = new DateTime.now();
  var selectedToDate = new DateTime.now();

  int? branchId;
  // new DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  initialise(int staffType, DateTime stDate, DateTime endDate) {
    dbUser = User();
    dbUser.initiliase();
    dbUser
        .customerRportRead(Staff["id"], stDate, endDate, selectMt!, staffType)
        .then((value) {
      if (value != null) {
        setState(() {
          filterList = userLst = value!;
          // totalBalance = userLst[0]['totalAmount'];
        });
      }
    });
  }

  @override
  void initState() {
    setState(() {
      selectedFromDate = DateTime(today.year, today.month + 0, 1);
      selectedToDate =
          DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    });
    loginData();
    super.initState();
  }

  File? f;
  int _counter = 0;

  User db = User();
  late int staffType;
  var Staff;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    // print(selectedStratDate);
    // print(selectedFromDate);
    // print("=========");
    // // print(selectedEndDate);
    // print(selectedToDate);
    initialise(staffType, selectedFromDate, selectedToDate);
  }

  List peymentmthd = ["All", "Payment Proof", "Direct"];
  String? selectMt = "All";
  void _generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    rows.add(["name", "Paid amount", "Purchase Amount", "Balance"]);
    for (int i = 0; i < userLst.length; i++) {
      List<dynamic> row = [];
      row.add(userLst[i]["name"]);
      row.add(userLst[i]["paidAmount"]);
      row.add(userLst[i]["purchase"]);
      row.add(userLst[i]["custBalance"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    String file = "$dir";

    f = File(file + "/customer-report.csv");

    f!.writeAsString(csv);

    setState(() {
      _counter++;
    });

    Noti.showBigTextNotification(
        title: "Download Complete",
        body: "customer-report.csv",
        fln: flutterLocalNotificationsPlugin,
        payload: f);
    openFile();
  }

  Future<void> openFile() async {
    var filePath;

    if (f != null) {
      filePath = f;
      final _result = await OpenFile.open("${filePath}");
    } else {
      // User canceled the picker
    }

    setState(() {});
  }

  var _openResult = 'Unknown';

  _selectStDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedFromDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedFromDate)
      setState(() {
        selectedFromDate = DateTime(
            selected.year, selected.month, selected.day, 23, 59, 59, 999);
      });
  }

  _selectEndDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedToDate)
      setState(() {
        selectedToDate = DateTime(
            selected.year, selected.month, selected.day, 23, 59, 59, 999);
      });
  }

// from date
  _selectFromDate(BuildContext context) {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedFromDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day, 00, 00, 00, 000);
      });
    });
  }

  // to date

  _selectToDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedToDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day, 23, 59, 59, 999);
      });

      // filterData(selectedFromDate, selectedToDate);
    });
  }

  List filterList = [];
  final TextEditingController _searchQuery = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Customer Report"),
        actions: [],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 9, right: 9, top: 9, bottom: 9),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .16,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .09,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _selectFromDate(context);
                                // _selectStDate(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueGrey.shade200),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(10),
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "From Date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedFromDate),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize: 13),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            child: Center(
                              child: Container(
                                height: double.infinity,
                                width: .9,
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _selectToDate();
                                // _selectEndDate(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueGrey.shade200),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * .3,
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "To Date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedToDate),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize: 13),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      height: .6,
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10, top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // print(selectedFromDate);
                          // print("=========");

                          // print(selectedToDate);
                          setState(() {
                            userLst = [];
                            filterList = [];
                          });
                          dbUser = User();
                          dbUser.initiliase();
                          dbUser
                              .customerRportRead(Staff["id"], selectedFromDate,
                                  selectedToDate, selectMt!, staffType)
                              .then((value) => {
                                    setState(() {
                                      filterList = userLst = value!;
                                    })
                                  });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .2,
                          height: MediaQuery.of(context).size.height * .035,
                          decoration: BoxDecoration(
                              color: useColor.homeIconColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Text(
                            "Go",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Paymnt Methode : ${selectMt}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 100,
                    child: DropdownButton(
                      underline: SizedBox(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color.fromARGB(115, 0, 0, 0)),
                      isExpanded: true,
                      hint: Text(
                        "",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color.fromARGB(115, 0, 0, 0)),
                      ),
                      value: selectMt,
                      items: peymentmthd.map((item) {
                        return DropdownMenuItem(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item,
                                style: TextStyle(color: Colors.black),
                              ),
                            ));
                      }).toList(),
                      onChanged: (value) {
                        // print(value);
                        setState(() {
                          selectMt = value as String?;
                        });

                        // print(selectedFromDate);
                        // print("=========");

                        // print(selectedToDate);
                        initialise(
                          staffType,
                          selectedFromDate,
                          selectedToDate,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchQuery,
              style: new TextStyle(
                color: Color.fromARGB(255, 38, 37, 37),
              ),
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search,
                      color: Color.fromARGB(255, 6, 6, 6)),
                  hintText: "Search...",
                  hintStyle:
                      new TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              onChanged: (string) {
                setState(() {
                  filterList = userLst
                      .where((element) =>
                          (element['custId']
                              .toLowerCase()
                              .contains(string.toLowerCase())) ||
                          (element['name']
                              .toLowerCase()
                              .contains(string.toLowerCase())) ||
                          (element['phoneNo']
                              .toLowerCase()
                              .contains(string.toLowerCase())))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: filterList != null
                      ? filterList.length > 0
                          ? ListView.builder(
                              itemCount: filterList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerViewScreen(
                                                    dbUser: db,
                                                    user: filterList[index])));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 100,
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor:
                                                          Colors.grey.shade400,
                                                      child: Icon(
                                                        Icons.account_box,
                                                        size: 18,
                                                        color: Colors.white,
                                                      )),
                                                  Text(
                                                    "${filterList[index]["name"]}"
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${filterList[index]["custId"]}"
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Paid Amount : ",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                                ["paidAmount"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Purchase : ",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                                ["purchase"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: .6,
                                                    color: Colors
                                                        .blueGrey.shade100,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Balance : ",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                                ["custBalance"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 10,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                    ],
                                  ),
                                );
                              })
                          : Center(
                              child: Text(
                                "No data Available",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            )
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          height: 100,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Convert to Excel",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .5,
                  height: MediaQuery.of(context).size.height * .05,
                  decoration: BoxDecoration(
                      color: useColor.homeIconColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      // getCsv();

                      _generateCsvFile();
                    },
                    child: Text(
                      "convert",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
