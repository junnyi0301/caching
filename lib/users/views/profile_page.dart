import 'dart:io';
import 'package:caching/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:caching/users/services/profile_service.dart';
import 'package:caching/users/model/profile.dart';
import 'package:caching/users/views/edit_profile_page.dart';
import 'package:caching/rewards/view/rewards.dart';
import 'package:caching/utilities/design.dart';
import 'package:caching/auth/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ProfileService();
    final design = Design();

    return Scaffold(
      backgroundColor: design.secondaryColor,
      bottomNavigationBar: BottomNav(currentIndex: 4),
      body: SafeArea(
        child: StreamBuilder<Profile?>(
          stream: service.getProfileStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final profile = snap.data;
            if (profile == null) {
              return const Center(child: Text("No profile data."));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    color: design.primaryColor,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: profile.photoUrl.isNotEmpty
                              ? (profile.photoUrl.startsWith('http')
                              ? NetworkImage(profile.photoUrl)
                              : FileImage(File(profile.photoUrl))) as ImageProvider
                              : const AssetImage('assets/images/blank_image.jpg'),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      color: design.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("UserID: ${profile.uid}"),
                            const SizedBox(height: 8),
                            const Text(
                              "Gender",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(profile.gender),
                            const SizedBox(height: 8),
                            const Text(
                              "Age",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(profile.age.toString()),
                            const SizedBox(height: 8),
                            const Text(
                              "Description",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: Text(profile.description),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Edit Profile button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design.primaryButton,
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.edit, color: Colors.black),
                            Text(
                              "Edit Profile",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Rewards button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RewardsPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design.primaryButton,
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.card_giftcard, color: Colors.black),
                            Text(
                              "Rewards",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const AuthGate()),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: design.primaryButton,
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.logout, color: Colors.black),
                            Text(
                              "Log Out",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
