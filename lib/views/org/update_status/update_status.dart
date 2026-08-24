import 'package:aidora/views/org/update_status/update_status_two.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aidora/controllers/form_controller.dart';

// ignore: must_be_immutable
class Updatestatus extends StatelessWidget {
  Updatestatus({super.key, required this.index});

  final int index;

  final FormController controller = Get.find();
  late Map<String, Object> item;

  @override
  Widget build(BuildContext context) {
    item = controller.taskInTask[index];
    return Scaffold(
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: _card(),
            ),
          ),
          item['status'] == 'pending' ? _bottomUpdate() : Container(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _header() {
    return AppBar(title: Center(child: Text("Task Details")));
  }

  Widget _card() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _state(text: item["status"].toString()),
          SizedBox(height: 20),
          _title(title: item["title"].toString()),
          SizedBox(height: 20),
          _row(
            icon: Icons.date_range,
            text: "Date & Time",
            value: item["created_at_display"].toString(),
          ),
          SizedBox(height: 20),
          _row(
            icon: Icons.location_on_outlined,
            text: "location",
            value: item["location"].toString(),
          ),
          SizedBox(height: 20),
          _row(
            icon: Icons.business_outlined,
            text: "Organization",
            value: item["organization_name"].toString(),
          ),
          SizedBox(height: 20),
          _description(des: item["task_description"].toString()),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  //////////////////////// _state ////////////////////////
  Widget _state({required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: item['status'] == 'pending' ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      height: 50,
      width: 80,
      child: Center(child: Text(text, textAlign: TextAlign.start)),
    );
  }

  //////////////////////// _title ////////////////////////
  Widget _title({required String title}) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  //////////////////////// _row ////////////////////////
  Widget _row({
    required IconData icon,
    required String text,
    required String value,
  }) {
    return Row(
      children: [
        CircleAvatar(child: Icon(icon, color: const Color(0xff7AD081))),
        SizedBox(width: 10),
        Column(
          children: [
            Text(text, style: TextStyle(color: Colors.blueGrey)),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //////////////////////// _Description ////////////////////////
  Widget _description({required String des}) {
    return Column(
      children: [
        Text("Task Description"),
        SizedBox(height: 10),
        Text(des, style: TextStyle(color: Colors.blueGrey)),
      ],
    );
  }

  ////////////////////////_bottomUpdate ////////////////////////
  Widget _bottomUpdate() {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Color(0xff7AD081),
        borderRadius: BorderRadius.circular(30),
      ),
      child: MaterialButton(
        onPressed: () {
          Get.to(() => Updatestatustwo(index: index));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined),
            SizedBox(width: 10),
            Text(
              "Update Task Status",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
