// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';

class LogScreen extends StatelessWidget {
  final Function set;
  const LogScreen(this.set);
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Builder(
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset:
              true, //Not move widgets up when keyboard appear
          body: SingleChildScrollView(
            child: Stack(
              children: [
                ClipPath(
                  child: Opacity(
                    opacity: 0.8,
                    child: Image(
                      height: height / 2 + 100,
                      width: double.infinity,
                      image: const AssetImage('assets/images/Bg.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  clipper: ImageClip(height, width),
                ),
                Center(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: height * 0.22,
                          width: width * 0.8,
                          child:
                              LayoutBuilder(builder: ((context, constraints) {
                            return Column(children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              Text(
                                'E-Market',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: constraints.maxWidth * 0.09,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: constraints.maxHeight * 0.1,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: constraints.maxHeight * 0.20,
                                  child: Icon(
                                    Icons.shopping_cart_rounded,
                                    color: Colors.white,
                                    size: constraints.maxHeight * 0.25,
                                  ),
                                ),
                              ),
                            ]);
                          })),
                        ),
                        LoginWidget(set),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoginWidget extends StatefulWidget {
  final Function set;
  const LoginWidget(this.set);
  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  var islog = true;
  var passwordVis = false;
  var usr = FocusNode();
  var pass = FocusNode();
  var conf = FocusNode();
  var but = FocusNode();
  var formkey = GlobalKey<FormState>();
  dynamic usrname, pwd, cnf;
  var a = SellerPost.authentication;

  Future show(str1, str2) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(str1),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (str1 == "Sucess!!!") {
                      setState(() {
                        islog = true;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                )
              ],
              content: Text(
                  str1 == "Sucess!!!" ? str2 : str2.toString().split('] ')[1]),
            ));
  }

  void logchange(val) {
    islog = val;
    formkey.currentState!.reset();
  }

  @override
  void dispose() {
    super.dispose();
    usr.dispose();
    formkey.currentState != null ? formkey.currentState!.dispose() : null;
    pass.dispose();
    but.dispose();
    conf.dispose();
  }

  Future<void> save(SellerPost sp) async {
    FocusScope.of(context).requestFocus(but);
    formkey.currentState!.save();
    if (formkey.currentState!.validate() == false) {
      return;
    }
    if (islog) {
      try {
        await a.signInWithEmailAndPassword(
          email: usrname.toString().trim(),
          password: pwd.toString().trim(),
        );
        if (a.currentUser!.emailVerified) {
          sp.updater();
          sp.getSellerType(usrname);
          widget.set();
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const Text(
                  "Please Verify Your Mail..",
                )),
          ));
        }
      } catch (error) {
        show("Error!!!", error);
      }
      return;
    } else {
      try {
        var res = await a.createUserWithEmailAndPassword(
          email: usrname.toString().trim(),
          password: pwd.toString().trim(),
        );
        show("Sucess!!!", "Verify Email Sended to your mail..");
        await res.user!.sendEmailVerification();
      } catch (error) {
        show("Alert!!!", error);
      }
    }
  }

  void forgotPassword() async {
    formkey.currentState!.save();
    if (usrname == null || usrname == "") {
      show("Alert!!!", "alert ] Enter Username");
      return;
    }
    try {
      await SellerPost.authentication.sendPasswordResetEmail(email: usrname);
      show("Sucess!!!", "Password change mail send Successfull!!!");
    } catch (error) {
      show("Alert!!!", error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<SellerPost>(context, listen: false);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        //login and signup navigator
        Container(
          alignment: Alignment.center,
          width: width * 0.8 / 1.70,
          height: height * 0.105,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      color: Colors.transparent,
                      decoration: islog
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationThickness: 2,
                      decorationColor: Colors.white,
                      shadows: [
                        Shadow(
                          color: islog ? Colors.white : Colors.black,
                          offset: const Offset(0, -10),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    logchange(true);
                  });
                },
              ),
              Text(
                '|',
                style: TextStyle(
                  fontSize: width * 0.045,
                  color: Colors.transparent,
                  shadows: const [
                    Shadow(color: Colors.black45, offset: Offset(0, -10))
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      color: Colors.transparent,
                      fontSize: width * 0.045,
                      decoration: !islog
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationThickness: 2,
                      decorationColor: Colors.white,
                      shadows: [
                        Shadow(
                          color: !islog ? Colors.white : Colors.black,
                          offset: const Offset(0, -10),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    logchange(false);
                  });
                },
              )
            ],
          ),
        ),
        //Form Widget.....
        Container(
          constraints: BoxConstraints(
              minHeight: height * 0.25, maxHeight: height * 0.50),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white),
          padding: const EdgeInsets.all(20),
          width: width * 0.85,
          child: SingleChildScrollView(
            child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      focusNode: usr,
                      decoration: const InputDecoration(
                          label: Text("E-mail"), prefixIcon: Icon(Icons.mail)),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(pass);
                      },
                      onSaved: (str) {
                        usrname = str!;
                      },
                      validator: (str) {
                        if (str == null || str == "" || !str.contains('@')) {
                          return "Enter mail id";
                        }
                        return null;
                      },
                    ),
                    if (islog) ...[
                      TextFormField(
                        obscureText: !passwordVis,
                        keyboardType: TextInputType.text,
                        focusNode: pass,
                        decoration: InputDecoration(
                            label: const Text("Password"),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: passwordVis
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  passwordVis = !passwordVis;
                                });
                              },
                            )),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(conf);
                          pwd = _;
                        },
                        onSaved: (str) {
                          pwd = str!;
                        },
                        validator: (str) {
                          if (str == null || str == "") {
                            return "Enter Password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        child: Text(
                          "Forgot Password?",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: forgotPassword,
                      )
                    ],
                    if (!islog) ...[
                      TextFormField(
                        obscureText: !passwordVis,
                        keyboardType: TextInputType.text,
                        focusNode: pass,
                        decoration: const InputDecoration(
                          label: Text("Password"),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(conf);
                          pwd = _;
                        },
                        onSaved: (str) {
                          pwd = str!;
                        },
                        validator: (str) {
                          if (str == null || str == "") {
                            return "Enter Password";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        obscureText: !passwordVis,
                        keyboardType: TextInputType.text,
                        focusNode: conf,
                        decoration: const InputDecoration(
                            label: Text("Confirm Password"),
                            prefixIcon: Icon(Icons.lock)),
                        onSaved: (str) {
                          cnf = str!;
                        },
                        validator: (str) {
                          if (str == null || str == "") {
                            return "Enter Password";
                          }
                          if (str.compareTo(pwd) != 0) {
                            return "Password not matched!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: passwordVis,
                              onChanged: (val) {
                                setState(() {
                                  passwordVis = !passwordVis;
                                });
                              }),
                          Text(
                            "Show Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )),
          ),
        ),
        //form button
        Container(
          margin: const EdgeInsets.all(15),
          width: width * 0.4,
          child: ElevatedButton(
              onPressed: () {
                save(pro);
              },
              focusNode: but,
              child: Text(
                islog ? "LOG IN" : "SIGN UP",
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              )),
        ),
      ],
    );
  }
}

//custom image clipper in flutter
class ImageClip extends CustomClipper<Path> {
  var height = 0.0, width = 0.0;
  ImageClip(this.height, this.width);
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, height / 2);
    path.quadraticBezierTo(width / 2, height / 2 + 100, width, height / 2);
    path.lineTo(width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
