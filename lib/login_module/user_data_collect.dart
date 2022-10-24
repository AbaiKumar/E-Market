// ignore_for_file: use_key_in_widget_constructors

import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:market/common_widget/location_pick.dart';

class UserDataCollect extends StatefulWidget {
  @override
  State<UserDataCollect> createState() => _UserDataCollectState();
}

class _UserDataCollectState extends State<UserDataCollect> {
  int _currentStep = 0;
  StepperType stepperType = StepperType.vertical;
  String? dropDownValue;
  List dropdown = ["Seller", "Buyer", "Driver"];
  late ValueNotifier<List> notifier;
  late TextEditingController name;
  late TextEditingController cname;
  late TextEditingController number;
  late TextEditingController street;
  late TextEditingController vehicle;
  late TextEditingController city;
  late TextEditingController state;

  @override
  void dispose() {
    super.dispose();
    street.dispose();
    name.dispose();
    city.dispose();
    state.dispose();
    cname.dispose();
    number.dispose();
  }

  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier([]);
    name = TextEditingController();
    number = TextEditingController();
    cname = TextEditingController();
    street = TextEditingController();
    city = TextEditingController();
    vehicle = TextEditingController();
    state = TextEditingController();
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 1 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  void fun(ctx) async {
    List? p = await pick(ctx);
    if (p != null) {
      notifier.value = p.toList();
    }
  }

  void a(txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  void save(String? res1, String? res2, SellerPost _) async {
    try {
      var uid = res1.toString(),
          nm = name.text.toString(),
          mail = res2.toString(),
          mob = number.text.toString(),
          typ = dropDownValue.toString(),
          companyname = cname.text.toString(),
          strt = street.text.toString(),
          cty = city.text.toString(),
          stat = state.text.toString(),
          lat = notifier.value[0].toString(),
          lon = notifier.value[1].toString(),
          veh = vehicle.text.toString();
      if (dropDownValue.toString() == "Driver") {
        if (veh.isEmpty ||
            uid.isEmpty ||
            nm.isEmpty ||
            mail.isEmpty ||
            mob.isEmpty ||
            mob.length < 10 ||
            mob.length > 10 ||
            typ.isEmpty ||
            strt.isEmpty ||
            cty.isEmpty ||
            stat.isEmpty ||
            lat.isEmpty ||
            lon.isEmpty) {
          a("Fill all details correctly");
          return;
        }
      }
      if (dropDownValue != "Driver" &&
          (uid.isEmpty ||
              nm.isEmpty ||
              mail.isEmpty ||
              mob.isEmpty ||
              mob.length < 10 ||
              mob.length > 10 ||
              typ.isEmpty ||
              companyname.isEmpty ||
              strt.isEmpty ||
              cty.isEmpty ||
              stat.isEmpty ||
              lat.isEmpty ||
              lon.isEmpty)) {
        a("Fill all details correctly");
        return;
      }
      String url = "https://abai-194101.000webhostapp.com/post.php";
      var response = await http.post(
        Uri.parse(url),
        body: {
          "uid": uid,
          "name": nm,
          "email": mail,
          "mobile": mob,
          "type": typ,
          "company": companyname,
          "street": strt,
          "city": cty,
          "state": stat,
          "lat": lat,
          "lon": lon,
          "veh": veh,
        },
      );

      if (response.body.isNotEmpty) {
        a("Data added Sucessfully");
        _.isDataContainInMysql(true, dropDownValue.toString());
        _.updateToken();
      } else {
        a("Data not added");
      }
    } catch (error) {
      a("Enter all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    var _ = Provider.of<SellerPost>(context, listen: false);
    var auth = SellerPost.authentication;
    _.updater();
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: stepperType,
                physics: const ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                controlsBuilder: (context, control) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10)),
                          onPressed: _currentStep == 0
                              ? continued
                              : () => save(auth.currentUser!.uid,
                                  auth.currentUser!.email, _),
                          child: _currentStep == 1
                              ? const Text("submit")
                              : const Text("Continue"),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        TextButton(
                          onPressed: cancel,
                          child: const Text("Back"),
                        ),
                      ],
                    ),
                  );
                },
                onStepCancel: cancel,
                steps: <Step>[
                  Step(
                    title: const Text('Personal Details'),
                    content: Column(
                      children: <Widget>[
                        TextField(
                          controller: name,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: number,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Mobile Number'),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15, bottom: 15),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                                icon: const Icon(Icons.arrow_drop_down_circle),
                                iconEnabledColor: Colors.green,
                                isExpanded: true,
                                hint: const Text("select type of login"),
                                value: dropDownValue,
                                items: [
                                  ...dropdown.map((e) {
                                    return DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
                                    );
                                  }).toList(),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    dropDownValue = v.toString();
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: const Text('Residential Address'),
                    content: Column(
                      children: <Widget>[
                        if (dropDownValue != "Driver")
                          TextField(
                            controller: cname,
                            decoration: const InputDecoration(
                                labelText: 'Company Name'),
                          ),
                        TextField(
                          controller: street,
                          decoration:
                              const InputDecoration(labelText: 'Street'),
                        ),
                        TextField(
                          controller: city,
                          decoration: const InputDecoration(labelText: 'City'),
                        ),
                        TextField(
                          controller: state,
                          decoration: const InputDecoration(labelText: 'State'),
                        ),
                        if (dropDownValue == "Driver")
                          TextField(
                            controller: vehicle,
                            decoration: const InputDecoration(
                                labelText: 'Vehicle Number'),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 15, bottom: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10)),
                            onPressed: () => fun(context),
                            child: const Text("Pick Location"),
                          ),
                        )
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
