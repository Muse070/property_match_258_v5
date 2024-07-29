//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:property_match_258_v4/common_widgets/app_buttons.dart';
// import 'package:property_match_258_v4/common_widgets/app_large_text.dart';
// import 'package:property_match_258_v4/common_widgets/app_text.dart';
// import 'package:property_match_258_v4/common_widgets/responsive_button.dart';
// import 'package:property_match_258_v4/cubit/app_cubit.dart';
// import 'package:property_match_258_v4/cubit/app_cubit_states.dart';
//
// class DetailPage extends StatefulWidget {
//   const DetailPage({super.key});
//
//   @override
//   State<DetailPage> createState() => _DetailPageState();
// }
//
// class _DetailPageState extends State<DetailPage> {
//   int gottenStars=3;
//   int selectedIndex=-1;
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AppCubits, CubitStates>(builder: (context, state){
//       DetailState detail = state as DetailState;
//       return Scaffold(
//           body: SizedBox(
//             width: double.maxFinite,
//             height: double.maxFinite,
//             child: Stack(
//               children: [
//                 Positioned(
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       width: double.maxFinite,
//                       height: 350,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                             image: NetworkImage("http://mark.bslmeivu.com/uploads/${detail.places.img}"),
//                             fit: BoxFit.cover
//                         ),
//                       ),
//                     )
//                 ),
//                 Positioned(
//                     left: 20,
//                     top:60,
//                     child: Row(
//                       children: [
//                         IconButton(onPressed: (){
//                           BlocProvider.of<AppCubits>(context).goHome();
//                         }, icon: const Icon(Icons.menu),
//                         )
//                       ],
//                     )),
//                 Positioned(
//                     top: 320,
//                     child: Container(
//                       padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
//                       width: MediaQuery.of(context).size.width,
//                       height: 600,
//                       decoration: const BoxDecoration(
//                           color: Colors.white10,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30),
//                             topRight: Radius.circular(30),
//                           )
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               AppLargeText(text: "Palm Trees", color: Colors.black87,),
//                               AppLargeText(text: "\$ 250", color: Colors.black54,)
//                             ],
//                           ),
//                           const SizedBox(height: 10,),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on, color: Colors.black54),
//                               const SizedBox(width: 5,),
//                               AppText(text: "Roma Park, Lusaka", color: Colors.black54,),
//                             ],
//                           ),
//                           const SizedBox(height: 20,),
//                           Row(
//                             children: [
//                               Wrap(
//                                 children: List.generate(5, (index){
//                                   return Icon(Icons.star, color: index<gottenStars?Colors.yellow:Colors.black87,);
//                                 }),
//                               ),
//                               const SizedBox(width: 10,),
//                               AppText(text: "(4.0)", color: Colors.black38,)
//                             ],
//                           ),
//                           const SizedBox(height: 25,),
//                           AppLargeText(text: "People", color: Colors.black.withOpacity(0.8), size: 20),
//                           const SizedBox(height: 5,),
//                           AppText(text: "Number of Rooms", color: Colors.black54,),
//                           const SizedBox(height: 10,),
//                           Wrap(
//                               children: List.generate(5, (index) {
//                                 return InkWell(
//                                   onTap: (){
//                                     setState(() {
//                                       selectedIndex=index;
//                                     });
//                                   },
//                                   child: Container(
//                                     margin: const EdgeInsets.only(right: 10),
//                                     child: AppButtons(size: 50,
//                                       color: selectedIndex==index?Colors.white:Colors.black,
//                                       backgroundColor: selectedIndex==index?Colors.black:const Color(0xFF5d69b3),
//                                       borderColor: selectedIndex==index?Colors.black:const Color(0xFF5d69b3),
//                                       text:(index+1).toString(),
//                                     ),
//                                   ),
//                                 );
//                               })
//                           ),
//                           const SizedBox(height: 20,),
//                           AppLargeText(text: "Description", color:Colors.black.withOpacity(0.8), size: 20,),
//                           const SizedBox(height: 10,),
//                           AppText(text: "You must go for a travel. Travelling helps get rid of pressure. Go to the mountains to see nature.", color: Colors.black54,)
//                         ],
//                       ),
//                     )),
//                 Positioned(
//                     bottom: 20,
//                     left: 20,
//                     right: 20,
//                     child: Row(
//                       children: [
//                         AppButtons(
//                             size: 60,
//                             color: Colors.grey,
//                             backgroundColor: Colors.white,
//                             borderColor: Colors.grey,
//                             isIcon: true,
//                             icon:Icons.favorite_border),
//                         const SizedBox(width: 20,),
//                         ResponsiveButton(
//                           isResponsive: true,
//                         )
//                       ],
//                     )
//                 )
//               ],
//             ),
//           )
//       );
//     });
//   }
// }
