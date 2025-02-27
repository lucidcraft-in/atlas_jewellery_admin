import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constant/colors.dart';
import '../providers/cmpService.dart';

class CmpPayment extends StatefulWidget {
  const CmpPayment({super.key});

  @override
  State<CmpPayment> createState() => _CmpPaymentState();
}

class _CmpPaymentState extends State<CmpPayment> {
  TextEditingController upiCntrl = TextEditingController();
  TextEditingController acNoCntrl = TextEditingController();
  TextEditingController ifscCntrl = TextEditingController();
  bool isLoad = false;
  String? ext;
  var normalsize;
  var compressSize;
  File? image;
  File? compressedImage;
  String? pickedImage;
  String fileName = "";

  @override
  void initState() {
    super.initState();
    getUpiDtails();
  }

  @override
  void dispose() {
    upiCntrl.dispose();
    super.dispose();
  }

  String docid = "";

  String backImage = "";
  String oldName = "";
  getUpiDtails() async {
    // Fetch data from the backend
    final companyService = Provider.of<CompanyService>(context, listen: false);
    var qrDetails = await companyService.readQr();
    // print("---------");
    // print(qrDetails);
    if (qrDetails != null) {
      setState(() {
        backImage = qrDetails[0]["qrcode"];
        // Assume `qrDetails.image` is a File or null
        upiCntrl.text =
            qrDetails[0]["upiId"]; // Assume `qrDetails.upiId` is a String
        acNoCntrl.text = qrDetails[0]["acNo"];
        ifscCntrl.text = qrDetails[0]["ifsc"];
        fileName =
            qrDetails[0]["qrname"]; // Assume `qrDetails.fileName` is a String
        oldName = qrDetails[0]["qrname"];
        docid = qrDetails[0]["id"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Payment Details',
          style: TextStyle(fontSize: 15),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 244, 231, 214),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .4,
                    width: MediaQuery.of(context).size.width * .7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: fileName != ""
                        ? backImage != ""
                            ? Image.network(
                                backImage) // Display the selected or backend image
                            : Image.file(image!)
                        : Image.asset("assets/images/qr.png"),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * .4,
                    height: MediaQuery.of(context).size.width * .1,
                    child: ElevatedButton(
                      onPressed: () {
                        imagePick(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              useColor.homeIconColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Upload QR Code",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (fileName != "") SizedBox(height: 5),
                  if (fileName != "")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileName,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            setState(() {
                              image = null;
                              fileName = "";
                              backImage = "";
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  SizedBox(height: 40),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: upiCntrl,
                          decoration: InputDecoration(
                              hintText: "Enter UPI ID",
                              labelText: "Enter UPI ID")),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: acNoCntrl,
                        decoration: InputDecoration(
                            hintText: "Enter Account No",
                            labelText: "Enter Account No"),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: ifscCntrl,
                          decoration: InputDecoration(
                              hintText: "Enter IFSC", labelText: "Enter IFSC")),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.width * .1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (image != null && upiCntrl.text.isNotEmpty) {
                          setState(() {
                            isLoad = true;
                          });
                          if (isLoad) {
                            submit();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Upload Qrcode and UPI ID...!')));
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              useColor.homeIconColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          isLoad == false
                              ? Text(
                                  "Update Payment Details",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to pick image
  imagePick(context) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return null;
    }

    setState(() {
      pickedImage = pickedFile.files.single.path;
      fileName = pickedFile.files.single.name;
      image = File(pickedImage!);
    });
  }

  // Method to submit the payment details
  submit() async {
    Provider.of<CompanyService>(context, listen: false)
        .createQrcode(docid, image!, fileName, upiCntrl.text, oldName,
            acNoCntrl.text, ifscCntrl.text)
        .then((value) {
      setState(() {
        isLoad = false;
      });
      if (value == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Payment Details Successfully Updated...')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong!')));
      }
    });
  }
}
