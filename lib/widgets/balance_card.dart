import 'package:flutter/material.dart';
import '../core/design_system/app_theme.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Profile and Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            'Jerry Vance Anguzu',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white, size: 26),
                        onPressed: () {
                          // Search functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                        onPressed: () {
                          // Notifications
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Balance Section
              Text(
                'Total Balance',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'UGX ',
                    style: AppTheme.heading4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isBalanceHidden ? '••••••••' : '2,444,562',
                    style: AppTheme.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceHidden = !_isBalanceHidden;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isBalanceHidden ? 'Show' : 'Hide',
                            style: AppTheme.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Top-up Button (Centered and smaller)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/top-up');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2AC4F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text(
                      'Top-up Wallet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import '../core/design_system/app_theme.dart';

// class BalanceCard extends StatelessWidget {
//   const BalanceCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.35,
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top Bar with Profile and Icons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Colors.white.withOpacity(0.2),
//                         child: const Icon(
//                           Icons.person,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome back',
//                             style: AppTheme.bodySmall.copyWith(
//                               color: Colors.white.withOpacity(0.8),
//                             ),
//                           ),
//                           Text(
//                             'John Doe',
//                             style: AppTheme.bodyLarge.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.search, color: Colors.white, size: 26),
//                         onPressed: () {
//                           // Search functionality
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
//                         onPressed: () {
//                           // Notifications
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 24),
              
//               // Balance Section
//               Text(
//                 'Total Balance',
//                 style: AppTheme.bodyMedium.copyWith(
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Text(
//                     'UGX ',
//                     style: AppTheme.heading3.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     '2,444,562',
//                     style: AppTheme.heading1.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 36,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.visibility_off,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Hide',
//                           style: AppTheme.caption.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
              
//               const Spacer(),
              
//               // Top-up Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Top-up wallet
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2AC4F3),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                   ),
//                   icon: const Icon(Icons.add_circle_outline, size: 20),
//                   label: const Text(
//                     'Top-up Wallet',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import '../core/design_system/app_theme.dart';

// class BalanceCard extends StatefulWidget {
//   const BalanceCard({super.key});

//   @override
//   State<BalanceCard> createState() => _BalanceCardState();
// }

// class _BalanceCardState extends State<BalanceCard> {
//   bool _isBalanceVisible = true;

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
    
//     return Container(
//       width: double.infinity,
//       height: screenHeight * 0.30,
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryColor.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             children: [
//               // Profile and Notification Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 25,
//                         backgroundColor: Colors.white,
//                         child: Text(
//                           'AVJ',
//                           style: AppTheme.bodyLarge.copyWith(
//                             color: AppTheme.primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome back,',
//                             style: AppTheme.bodySmall.copyWith(
//                               color: Colors.white.withOpacity(0.8),
//                             ),
//                           ),
//                           Text(
//                             'Anguzu Vance Jerry',
//                             style: AppTheme.bodyLarge.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/notifications');
//                     },
//                     icon: const Icon(
//                       Icons.notifications_outlined,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               // Balance Section - Centered
//               Column(
//                 children: [
//                   Text(
//                     'Total Balance',
//                     style: AppTheme.bodyMedium.copyWith(
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _isBalanceVisible ? 'UGX 1,500,000' : '******',
//                         style: AppTheme.heading1.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 36,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _isBalanceVisible = !_isBalanceVisible;
//                           });
//                         },
//                         icon: Icon(
//                           _isBalanceVisible
//                               ? Icons.visibility_outlined
//                               : Icons.visibility_off_outlined,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   // Top Up Button - Centered below balance
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/top-up');
//                     },
//                     icon: const Icon(Icons.add, size: 20),
//                     label: const Text('Top Up Wallet'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: AppTheme.primaryColor,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import '../core/design_system/app_theme.dart';

// class BalanceCard extends StatelessWidget {
//   const BalanceCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryColor.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total Balance',
//                 style: AppTheme.bodyMedium.copyWith(
//                   color: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.trending_up,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '+2.5%',
//                       style: AppTheme.caption.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             '\$24,562.80',
//             style: AppTheme.heading1.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Available to spend',
//             style: AppTheme.bodyMedium.copyWith(
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Card Number',
//                       style: AppTheme.caption.copyWith(
//                         color: Colors.white.withOpacity(0.6),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '**** **** **** 4589',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Valid Thru',
//                       style: AppTheme.caption.copyWith(
//                         color: Colors.white.withOpacity(0.6),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '12/28',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
