import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/app_user.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 21, 41, 97),
              Color.fromARGB(255, 16, 3, 55),
              Color.fromARGB(255, 23, 63, 112),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [

                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 46,
                        color: Color(0xff1E3A8A),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "ALU Launch Pad",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Build. Connect. Invest.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Connecting ambitious students with innovative startups across ALU.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Choose your role",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Select how you'd like to use Launch Pad.",
                            style: theme.textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 28),

                          _RoleCard(
                            icon: Icons.school_rounded,
                            title: "Student",
                            subtitle:
                                "Discover internships, startup jobs and networking opportunities.",
                            color: const Color(0xff2563EB),
                            onTap: () {
                              context.push(
                                "/signup",
                                extra: UserRole.student,
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          _RoleCard(
                            icon: Icons.trending_up_rounded,
                            title: "Startup",
                            subtitle:
                                "Create opportunities, manage applications and grow your startup.",
                            color: const Color.fromARGB(131, 86, 61, 20),
                            onTap: () {
                              context.push(
                                "/signup",
                                extra: UserRole.startupAdmin,
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          Row(
                            children: const [

                              Expanded(child: Divider()),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("OR"),
                              ),

                              Expanded(child: Divider()),

                            ],
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                context.push("/login");
                              },
                              child: const Text("Already have an account? Log In"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [

            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded),
          ],
        ),
      ),
    );
  }
}