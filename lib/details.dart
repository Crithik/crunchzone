import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String image;
  final String name;
  final String price;

  DetailsPage({required this.image, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
        title: Text(
          name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600; 

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: isWideScreen
                ? Row( 
                    children: [
                      Expanded(
                        flex: 2, 
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100, color: Colors.black54);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(flex: 3, child: _productDetails()),
                    ],
                  )
                : Column( 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100, color: Colors.black54);
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _productDetails(), 
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Reusable Product Details Widget
  Widget _productDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          price,
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {},
            child: Text("Add to Cart"),
          ),
        ),
      ],
    );
  }
}
