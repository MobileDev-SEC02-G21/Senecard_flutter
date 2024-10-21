import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:senecard/view_models/owner/owner_page_vm.dart'; 
import 'package:senecard/views/elements/shared/sidemenu.dart';
import 'package:senecard/views/elements/shared/topbar.dart';
import 'advertisement_list.dart'; 
import 'qr_page.dart'; 

class OwnerPage extends StatefulWidget {
  final String storeId; 

  const OwnerPage({super.key, required this.storeId});

  @override
  State<OwnerPage> createState() {
    return _OwnerPageState();
  }
}

class _OwnerPageState extends State<OwnerPage> {
  List<MenuItem> menuItems = [
    MenuItem(title: 'Profile'),
    MenuItem(title: 'My Ads'),
    MenuItem(title: 'Settings'),
    MenuItem(title: 'Log Out'),
  ];

  @override
  void initState() {
    super.initState();
    
    final ownerPageViewModel = Provider.of<OwnerPageViewModel>(context, listen: false);

    
    ownerPageViewModel.fetchCustomersScannedToday(widget.storeId); 
    ownerPageViewModel.fetchStoreRating(widget.storeId); 
    ownerPageViewModel.fetchActiveAdvertisements(widget.storeId); 
  }

  @override
  Widget build(BuildContext context) {
    final ownerPageViewModel = Provider.of<OwnerPageViewModel>(context); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(
        backHome: () {},
        icon: const Icon(Icons.menu),
        title: "Welcome Back",
        message: "Let's Check Your Progress",
        trailing: [
          IconButton(
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrScanPage(storeId: widget.storeId), 
                ),
              );
            },
            icon: const Icon(Icons.qr_code),
            color: Colors.white,
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 122, 40)),
            ),
          ),
        ],
      ),
      drawer: SideMenuDrawer(
        storeId: widget.storeId,
        menuItems: menuItems,
      ),
      drawerScrimColor: const Color.fromARGB(255, 152, 168, 184),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50), 
            const Text(
              'Welcome Back To Senecard!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), 
            const Text(
              'You’ve had',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            Stack(
              alignment: Alignment.center,
              children: [
                
                Positioned(
                  top: 100, 
                  child: Container(
                    width: 200,
                    height: 100, 
                    color: Colors.white,
                  ),
                ),
                
                Container(
                  width: 200,
                  height: 100, 
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(100), 
                    ),
                  ),
                ),
                
                Positioned(
                  top: 25,
                  child: Column(
                    children: [
                      Text(
                        '${ownerPageViewModel.customersScannedToday}',  
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Customers scanned today\nKeep up the good work!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60), 
            const Text(
              'Current Business average Rating',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30), 
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < ownerPageViewModel.storeRating.floor()
                      ? Icons.star
                      : (index < ownerPageViewModel.storeRating.ceil() ? Icons.star_half : Icons.star_border),
                  color: Colors.orange,
                  size: 32,
                );
              }),
            ),
            const SizedBox(height: 60), 
            
            ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvertisementPage(storeId: widget.storeId), 
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, 
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOU HAVE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${ownerPageViewModel.activeAdvertisements} ADVERTISEMENTS ACTIVE',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
