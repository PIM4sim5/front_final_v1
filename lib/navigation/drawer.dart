import 'package:flutter/material.dart';
import 'package:flutter_node_auth/drawer_widgets/UploadScreenDrawer.dart';
import 'package:flutter_node_auth/models/user.dart';
//import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/screens/UploadScreen.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/drawer_widgets/ChatDrawer.dart';


class SidebarXExampleApp extends StatelessWidget {
  final User currentUser;
  final Widget body;
  SidebarXExampleApp({required this.currentUser, required this.body});

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatDB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
       // scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: canvasColor,
                    title: Text(_getTitleByIndex(_controller.selectedIndex)),
                    leading: IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller, currentUser: currentUser),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller, currentUser: currentUser),
                Expanded(
                  child: Center(
                    child: body,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
    required this.currentUser,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return  SizedBox(
          height: 150,
          child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ Padding(
            padding:const EdgeInsets.all(16.0),
            child: CircleAvatar(backgroundColor: Colors.amber,),
          ),
          Text(
            currentUser.name,
            style: TextStyle(color: Colors.white,fontSize: 16),
          ),
          ],
        ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
                               
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileUploadScreenWithDrawer(currentUser: currentUser),
                    ),
                  );
          },
        ),
//youssef chat
         SidebarXItem(
          icon: Icons.chat,
          label: 'Chat',
          onTap: () {
                               
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDrawer(currentUser: currentUser,),
                    ),
                  );
          },
        ),
      ],
    );
  }
}



String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Home';
    case 1:
      return 'Chat'; //youssef
    case 2:
      return 'Chat';

    
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);