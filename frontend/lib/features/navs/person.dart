import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/home/pages/edit_profile.dart';
import 'package:frontend/presentation/providers/theme_provider.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:provider/provider.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthLocalRepository().getUser();
    setState(() {
      _name = user?.name ?? 'No Name';
      _email = user?.email ?? 'No Email';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated')),
      );
    }
  }

  void _showPickOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Pick from Gallery"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 👇 Avatar and camera icon, both tappable
            GestureDetector(
              onTap: () {
                _showPickOptionsDialog(context);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[400],
                    backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(_email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    );
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 33),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                label: const Text('Edit Profile',
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C2C9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Logout?"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await AuthLocalRepository().clearUser();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C2C9),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Log out',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:frontend/features/auth/pages/login_page.dart';
// import 'package:frontend/features/home/pages/edit_profile.dart';
// import 'package:frontend/presentation/providers/theme_provider.dart';
// import 'package:frontend/features/auth/repository/auth_local_repository.dart';
// import 'package:provider/provider.dart';
//
// class Person extends StatefulWidget {
//   const Person({super.key});
//
//   @override
//   State<Person> createState() => _PersonState();
// }
//
// class _PersonState extends State<Person> {
//   String _name = 'Loading...';
//   String _email = 'Loading...';
//   File? _pickedImage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = await AuthLocalRepository().getUser();
//     setState(() {
//       _name = user?.name ?? 'No Name';
//       _email = user?.email ?? 'No Email';
//     });
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.only(top: 60),
//         child: Column(
//           children: [
//             const Text(
//               'Profile',
//               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundColor: Colors.grey,
//                   backgroundImage:
//                   _pickedImage != null ? FileImage(_pickedImage!) : null,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     _showPickOptionsDialog(context);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.black.withOpacity(0.6),
//                     ),
//                     padding: const EdgeInsets.all(6),
//                     child: const Icon(
//                       Icons.camera_alt,
//                       size: 20,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 _showPickOptionsDialog(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 elevation: 4,
//                 shadowColor: Colors.black45,
//                 backgroundColor: const Color(0xFF50C2C9),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.only(left: 60, right: 60),
//                 textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.image, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text('Pick an Image', style: TextStyle(color: Colors.white)),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//             Text(_name,
//                 style:
//                 const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(_email, style: const TextStyle(color: Colors.grey)),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Dark Mode", style: TextStyle(fontSize: 16)),
//                 const SizedBox(width: 10),
//                 Consumer<ThemeProvider>(
//                   builder: (context, themeProvider, child) {
//                     return Switch(
//                       value: themeProvider.isDarkMode,
//                       onChanged: (_) => themeProvider.toggleTheme(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 33),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const EditProfileScreen()),
//                   );
//                 },
//                 icon:
//                 const Icon(Icons.edit, size: 14, color: Colors.white),
//                 label: const Text('Edit Profile',
//                     style: TextStyle(fontSize: 12, color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF50C2C9),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text("Logout?"),
//                       content: const Text("Are you sure you want to logout?"),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text("Cancel"),
//                         ),
//                         ElevatedButton(
//                           onPressed: () async {
//                             await AuthLocalRepository().clearUser();
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const LoginPage()),
//                             );
//                           },
//                           child: const Text("Logout"),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF50C2C9),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text('Log out',
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showPickOptionsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               title: const Text("Pick from Gallery"),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               title: const Text("Take a Picture"),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
