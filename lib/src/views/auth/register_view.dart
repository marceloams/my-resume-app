import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_resume_app/constants.dart';
import 'package:my_resume_app/src/views/auth/login_view.dart';
import 'package:my_resume_app/src/views/widgets/buttons/custom_rounded_button.dart';
import 'package:my_resume_app/src/views/widgets/form/custom_box.dart';
import 'package:my_resume_app/src/views/widgets/form/custom_input_fields.dart';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Positioned(
                    right: 0.0,
                    child: Container(
                        child: SvgPicture.asset(
                            "assets/images/register_upbackground.svg"))),
                Positioned(
                    bottom: 0.0,
                    child: Container(
                      child: SvgPicture.asset(
                          "assets/images/register_downbackground.svg"),
                    )),
                Positioned(
                    left: 0.0,
                    child: RoundedButton(
                        BackButton(
                          color: primaryColor,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginView()));
                          },
                        ),
                        50.0,
                        50.0)),
                Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 230.0,
                    child: CustomBox(
                        292.0,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputFields(
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                null,
                                "Nome",
                                TextInputType.text,
                                false,
                                Colors.white),
                            Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white)))),
                            InputFields(
                                Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                null,
                                "E-mail",
                                TextInputType.emailAddress,
                                false,
                                Colors.white),
                            Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white)))),
                            InputFields(
                                Icon(Icons.vpn_key, color: Colors.white),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                ),
                                "Senha",
                                TextInputType.text,
                                true,
                                Colors.white),
                            Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white)))),
                            InputFields(
                                Icon(Icons.vpn_key, color: Colors.white),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                ),
                                "Confirmar senha",
                                TextInputType.text,
                                true,
                                Colors.white),
                          ],
                        ),
                        0.0,
                        primaryColor)),
                Positioned(
                  right: 0.0,
                  left: 0.0,
                  bottom: 200.0,
                  child: Container(
                    height: 55.0,
                    alignment: Alignment.center,
                    child: RaisedButton(
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                          decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: 215.0, minHeight: 60.0),
                            alignment: Alignment.center,
                            child: Text(
                              "REGISTRAR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}