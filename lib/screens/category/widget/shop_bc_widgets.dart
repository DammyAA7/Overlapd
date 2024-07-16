// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/home/models/product_model.dart';
import 'package:overlapd/screens/home/models/subcategory.dart';

class ProductListItemWidget extends StatelessWidget {
  ProductListItemWidget(this.product, {super.key});

  Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 174.0,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              8.0,
            ),
          ),
          // decoration: AppDecoration.outlineGray.copyWith(
          //   borderRadius: BorderRadiusStyle.roundedBorder8,
          // ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 97.0,
                width: 174.0,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // CustomImageView(
                    //   imagePath: ImageConstant.imgRectangle1,
                    //   height: 97.0.v,
                    //   width: 174.0.v,
                    //   radius: BorderRadius.circular(
                    //     8.0,
                    //   ),
                    //   alignment: Alignment.topCenter,
                    // ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 12.0,
                                      width: 12.0,
                                      padding: EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        // color:
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      // decoration: AppDecoration.outlineGray8002.copyWith(
                                      //   borderRadius: BorderRadiusStyle.roundedBorder8,
                                      // ),
                                      // child: CustomImageView(
                                      //   imagePath: productListItemModelObj.userImage,
                                      //   height: 7.0.adaptSize,
                                      //   width: 7.0.adaptSize,
                                      //   alignment: Alignment.center,
                                      // ),
                                    ),
                                    Container(
                                      width: 26.0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1.5,
                                        vertical: 1.0,
                                      ),
                                      decoration: BoxDecoration(
                                        // color:
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      // decoration: AppDecoration.outlineGray8002.copyWith(
                                      //   borderRadius: BorderRadiusStyle.circleBorder5,
                                      // ),
                                      child: Text(product.pricePer
                                          // style: CustomTextStyles.interElgrayA700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                height: 12.0,
                                width: 12.0,
                                padding: const EdgeInsets.all(1.0 * 2.0),
                                decoration: BoxDecoration(
                                  // color:
                                  borderRadius: BorderRadius.circular(
                                    8.0,
                                  ),
                                ),
                                // decoration: AppDecoration.fillPrimary.copyWith(
                                //   borderRadius: BorderRadiusStyle.roundedBorder8,
                                // ),
                                child: const Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7.0),
              Text(product.promotionalPrice
                  // style: theme.textTheme.bodySmall,
                  ),
              const SizedBox(height: 5.0),
              SizedBox(
                width: 44,
                child: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // style: CustomTextStyles.bodySmallPrimaryContainer.copyWith(
                  //   height: 1.33,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: must_be_immutable

class ViewHierarchyItemWidget extends StatelessWidget {
  ViewHierarchyItemWidget(this.product, this.onTap, {super.key});

  Product product;
  Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
      
        // decoration: AppDecoration.outlineGray.copyWith(
        //   borderRadius: BorderRadiusStyle.roundedBorder8,
        // ),
        width: 97.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 37.0,
              width: 77.7,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.network(
                    product.imageUrl,
                    height: 64,
                    width: 77,
                    alignment: Alignment.center,
                  ),
      
                  // CustomImageView(
                  //   imagePath: ImageConstant.imgRectangle1,
                  //   height: 64.0,
                  //   width: 77.7,
                  //   radius: BorderRadius.circular(
                  //     8.0,
                  //   ),
                  //   alignment: Alignment.topCenter,
                  // ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 12.0,
                      width: 12.0,
                      margin: EdgeInsets.only(right: 6.0),
                      padding: EdgeInsets.all(1.2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                      ),
                      // decoration: AppDecoration.fillPrimary.copyWith(
                      //   borderRadius: BorderRadiusStyle.roundedBorder8,
                      // ),
                      child: Icon(
                        Icons.add,
                        size: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 12.0,
                      width: 12.0,
                      margin: EdgeInsets.only(left: 5.0),
                      padding: EdgeInsets.all(1.1),
                      // decoration: AppDecoration.outlineGray300B2.copyWith(
                      //   borderRadius: BorderRadiusStyle.roundedBorder8,
                      // ),
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                      ),
                      child: Icon(Icons.remove),
                      // child: Image.network(viewHierarchyItemModelObj.image3!,
                      //  height: 7, width: 7 , alignment: Alignment.center,)
                      // child: CustomImageView(
                      //   imagePath: viewHierarchyItemModelObj.image3!,
                      //   height: 7.0,
                      //   width: 7.0,
                      //   alignment: Alignment.center,
                      // ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 26.0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.1,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        // color:
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                      ),
                      // decoration: AppDecoration.outlineGray300B2.copyWith(
                      //   borderRadius: BorderRadiusStyle.circleBorder5,
                      // ),
                      child: Text(
                        product.pricePer,
                        style:
                            TextStyle(fontSize: 6, fontWeight: FontWeight.w400),
                        // style: CustomTextStyles.interElgrayA700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 7.0),
            Text(
              product.price,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              // style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 5.0),
            SizedBox(
              width: 44.0,
              child: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffBABABA),
                ),
                // style: CustomTextStyles.bodySmallOnPrimaryContainer.copyWith(
                //   height: 1.30,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
