import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:iFresh_customer/screens/product/product_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Environment/Environment.dart';
import '../../constant/api.dart';
import '../../helper_widget/appbar_helper.dart';
import '../../helper_widget/imageShimmer.dart';
import '../add_to_cart/addto_cart_controller.dart';
import '../category/category_controller.dart';
import '../constant/colors.dart';
import '../constant/validations.dart';
import '../login/login_screen.dart';
import '../product_details/product_detail_screen.dart';

class Product extends StatefulWidget {
  final String name;
  final List<dynamic> CatData;
  final int catId;

  // const Product({super.key});
  const Product(
      {Key? key,
        required this.catId,
        required this.name,
        required this.CatData})
      : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  bool isLoading = true;

  // late String productId;
  // var attributesList;
  String productId = '';
  Map<int, String> selectedAttributes = {};
  Map<int, String> selectedAttributeIds = {};
  Map<int, double> selectedAttributePrices = {}; // New map to store price for selected attribute
  Map<int, double> selectedAttributeMrp = {};
  Map<int, int> selectedAttributeIndex = {};
  AddCartController addCartController = Get.put(AddCartController());
  Map<int, int> productQuantities = {};
  late String attributeIds;

  //List<Map<String, dynamic>> attributesList = [];
  @override
  initState() {
    super.initState();
    productController.productListData.clear();
    productController.allProductListData.clear();
    productController.ProductListLoading(true);

    productController.productListPaginationSearch(catId : widget.catId);
    productController.productSearchCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.update();
      productController.categoryId.value = widget.catId.toString();

      if (widget.catId == 0) {
        callProductWishLiat(productController.area_id.value);
      } else {
        getProductData();
      }
    });
  }


  getProductData() async {
    productController.productListData.clear();
    productController.allProductListData.clear();
    productController.ProductListLoading(true);
    productController.update();
    productController.productListPage = 1;
    productController.currentSearch =
        productController.productSearchCtrl.text;

    productController.currentOrderBy =
    selectedWeight == "A to Z" ? "asc" : "desc";
    productController.productListlimit = 10;
    if (selectedWeight != null) {
      if (selectedWeight == 'A to Z') {
        await productController.ProductListApiCall(
            productController.productSearchCtrl.text,
            'asc',
            productController.productListPage,
            productController.productListlimit,
            widget.catId,
            productController.area_id.value);
      } else if (selectedWeight == 'Z to A') {
        await productController.ProductListApiCall(
            productController.productSearchCtrl.text,
            'desc',
            productController.productListPage,
            productController.productListlimit,
            widget.catId,
            productController.area_id.value);
      }
    } else {
      await productController.ProductListApiCall(
          productController.productSearchCtrl.text,
          'desc',
          productController.productListPage,
          productController.productListlimit,
          widget.catId,
          productController.area_id.value);
      // setState(() {});
    }

    log('productListData==>' + productController.productListData.toString());
  }

  final ProductController productController = Get.put(ProductController());
  final CategoryController categoryController = Get.put(CategoryController());
  String? selectedWeight;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    attributeIds = '';
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: HelperAppBar(
        // title: toBeginningOfSentenceCase(widget.name) ?? '',
        //  title: toBeginningOfSentenceCase(widget.name) ?? 'My WishList',
        title: (widget.name == null || widget.name!.trim().isEmpty)
            ? 'My Wishlist'
            : toBeginningOfSentenceCase(widget.name) ?? '',
        displaySearch: false,
        displayCart: true,
      ),
      body: GetBuilder<ProductController>(builder: (productController) {
        if (productController.ProductListLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: primarylogin,
              strokeWidth: 2,
            ),
          );
        }
        return RefreshIndicator(
          color: primarylogin,
          onRefresh: () async {
            if (widget.name != null && widget.name!.trim().isNotEmpty)
              await getProductData();
          },
          child: CustomScrollView(
            controller: productController.ProductListScrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Search and Sort Section
              if (widget.name != null && widget.name!.trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: productController.productSearchCtrl,
                              cursorColor: primarylogin,
                              onChanged: (value) async {
                                productController.productListPage = 1;

                                await productController.ProductListApiCall(
                                  value,
                                  productController.currentOrderBy,
                                  1,
                                  productController.productListlimit,
                                  widget.catId,
                                  productController.area_id.value,
                                  priceOrder: productController.currentPriceOrder,
                                );
                              },
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Search products',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort Dropdown
                        Container(
                          height: 45,
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              value: selectedWeight,
                              hint: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort,
                                    size: 16,
                                    color: primarylogin,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sort',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              items: <String>[
                                'A to Z',
                                'Z to A',
                                'Low to High',
                                'High to Low'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                setState(() {
                                  selectedWeight = newValue;
                                });

                                productController.productListPage = 1;

                                if (newValue == 'A to Z') {
                                  await productController.ProductListApiCall(
                                    productController.productSearchCtrl.text,
                                    'asc',
                                    1,
                                    productController.productListlimit,
                                    widget.catId,
                                    productController.area_id.value,
                                  );
                                } else if (newValue == 'Z to A') {
                                  await productController.ProductListApiCall(
                                    productController.productSearchCtrl.text,
                                    'desc',
                                    1,
                                    productController.productListlimit,
                                    widget.catId,
                                    productController.area_id.value,
                                  );
                                } else if (newValue == 'Low to High') {
                                  await productController.ProductListApiCall(
                                    productController.productSearchCtrl.text,
                                    'desc',
                                    1,
                                    productController.productListlimit,
                                    widget.catId,
                                    productController.area_id.value,
                                    priceOrder: 'asc',
                                  );
                                } else if (newValue == 'High to Low') {
                                  await productController.ProductListApiCall(
                                    productController.productSearchCtrl.text,
                                    'desc',
                                    1,
                                    productController.productListlimit,
                                    widget.catId,
                                    productController.area_id.value,
                                    priceOrder: 'desc',
                                  );
                                }
                              },
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: primarylogin,
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Category Name with Subcategory Button
              if (widget.name != null && widget.name!.trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        displayBottomSheet(
                            context, widget.CatData, widget.name, size);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primarylogin.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: primarylogin,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.name,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Products Grid
              if (productController.productListData.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productController.productSearchCtrl.text.isEmpty
                              ? 'No products available'
                              : 'No product found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.59, // Adjusted for better content fit
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, productIndex) {
                        final product =
                        productController.productListData[productIndex];
                        List<dynamic> attributesList =
                            product['vendor_product_attributes'] ?? [];

                        // Prepare options for dropdown
                        // Prepare options for dropdown
                        List<String> weightOptions = [];
                        List<String> weightOptionIds = [];
                        List<double> weightOptionPrices = [];
                        List<double> weightOptionMrps = [];

                        if (attributesList.isNotEmpty) {
                          for (var attribute in attributesList) {
                            final details = attribute['attributes_details'] as List<dynamic>? ?? [];

                            final attributeId =
                                attribute['attribute_id']?.toString() ?? '';

                            final attributePrice =
                                double.tryParse(attribute['price']?.toString() ?? '') ?? 0.0;

                            final attributeMrp =
                                double.tryParse(attribute['mrp']?.toString() ?? '') ?? 0.0;

                            if (details.isNotEmpty) {
                              final formattedAttribute = details.join(', ');

                              // IMPORTANT:
                              // Yahan duplicate ko remove nahi karna.
                              // API se jitne attributes aaye hain, sab add honge.
                              weightOptions.add(formattedAttribute);
                              weightOptionIds.add(attributeId);
                              weightOptionPrices.add(attributePrice);
                              weightOptionMrps.add(attributeMrp);
                            }
                          }
                        }

// Initialize selected attribute
                        if (!selectedAttributes.containsKey(product['id']) &&
                            weightOptions.isNotEmpty) {
                          String firstAttribute = weightOptions.first;
                          selectedAttributeIndex[product['id']] = 0;

                          selectedAttributes[product['id']] = weightOptions[0];
                          selectedAttributeIds[product['id']] = weightOptionIds[0];
                          selectedAttributePrices[product['id']] = weightOptionPrices[0];
                          selectedAttributeMrp[product['id']] = weightOptionMrps[0];
                        }

// Price
                        double displayPrice = selectedAttributePrices.containsKey(product['id'])
                            ? selectedAttributePrices[product['id']]!
                            : double.tryParse(product['price'].toString()) ?? 0.0;

// ✅ FINAL MRP LOGIC (FIXED)
                        double mrp = 0.0;

                        if (selectedAttributeMrp.containsKey(product['id'])) {
                          mrp = selectedAttributeMrp[product['id']]!;
                        } else {
                          mrp = double.tryParse(product['product_mrp']?.toString() ?? '') ?? 0.0;
                        }

                        if (!productQuantities.containsKey(product['id'])) {
                          productQuantities[product['id']] = int.tryParse(
                              product['product_minimum_qty'].toString()) ??
                              1;
                        }

                        int minQty = int.parse(
                            product['product_minimum_qty'].toString());
                        int maxQty = int.parse(
                            product['product_maximum_qty'].toString());
                        int currentQty = productQuantities[product['id']]!;


                        int stockStatus = product['status'] ?? 0;

                        double rating = double.tryParse(product['avg_rating']?.toString() ?? '') ?? 0.0;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.to(ProductDetails(product_id: product['id']));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Product Image
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product['main_image'],
                                          height: size.height * 0.16,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return imageShimmer(
                                              height: size.height * 0.16,
                                              width: double.infinity,
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: size.height * 0.16,
                                              width: double.infinity,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[400],
                                                size: 30,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        left: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: stockStatus == 1
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(6),
                                                topRight: Radius.circular(6),topLeft: Radius.circular(4)),
                                          ),
                                          child: Text(
                                            stockStatus == 1 ? "In Stock" : "Out of Stock",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Favorite Button
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () async {
                                            bool checklogin =
                                                Environment.appuserlog;

                                            if (checklogin == true) {
                                              var likeUrl = Uri.parse(
                                                  productlike_url +
                                                      "${product['id'].toString()}");
                                              productController.LikeApiData(
                                                  likeUrl, productIndex);
                                            } else {
                                              Get.to(LoginPage());
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.favorite,
                                              color: productController
                                                  .productListData[
                                              productIndex]
                                              ['is_liked'] ==
                                                  false
                                                  ? Colors.grey[400]
                                                  : Colors.red,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),


                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Product Name
                                  SizedBox(
                                    height: size.height*0.05,
                                    child: Text(
                                      product['product_name'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Rating Row
                                  Row(
                                    children: [

                                      Container(
                                        height: 20,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: List.generate(5, (index) {
                                                return Icon(
                                                  Icons.star,
                                                  color: index < rating.floor()
                                                      ? Colors.amber
                                                      : Colors.grey[300],
                                                  size: 10,
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${rating.toStringAsFixed(1)}",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Spacer(),
                                      // Attribute Dropdown
                                      if (weightOptions.isNotEmpty)
                                        Container(
                                          height: 20,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              // IMPORTANT:
                                              // Selected value ab index hai, attribute text nahi.
                                              value: selectedAttributeIndex[product['id']],

                                              selectedItemBuilder: (BuildContext context) {
                                                return List.generate(
                                                  weightOptions.length,
                                                      (index) {
                                                    return Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        weightOptions[index],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },

                                              onChanged: (int? selectedIndex) {
                                                if (selectedIndex == null) return;

                                                setState(() {
                                                  // Save selected index
                                                  selectedAttributeIndex[product['id']] =
                                                      selectedIndex;

                                                  // Save actual attribute data
                                                  selectedAttributes[product['id']] =
                                                  weightOptions[selectedIndex];

                                                  selectedAttributeIds[product['id']] =
                                                  weightOptionIds[selectedIndex];

                                                  selectedAttributePrices[product['id']] =
                                                  weightOptionPrices[selectedIndex];

                                                  selectedAttributeMrp[product['id']] =
                                                  weightOptionMrps[selectedIndex];

                                                  // Attribute ID for API
                                                  attributeIds =
                                                  weightOptionIds[selectedIndex];
                                                });

                                                log(
                                                  'Selected Attribute Index: $selectedIndex',
                                                );

                                                log(
                                                  'Selected Attribute: '
                                                      '${weightOptions[selectedIndex]}',
                                                );

                                                log(
                                                  'Selected Attribute ID: '
                                                      '${weightOptionIds[selectedIndex]}',
                                                );

                                                log(
                                                  'Selected Attribute Price: '
                                                      '${weightOptionPrices[selectedIndex]}',
                                                );

                                                log(
                                                  'Selected Attribute MRP: '
                                                      '${weightOptionMrps[selectedIndex]}',
                                                );
                                              },

                                              items: List.generate(
                                                weightOptions.length,
                                                    (index) {
                                                  return DropdownMenuItem<int>(
                                                    // INDEX MUST BE UNIQUE
                                                    value: index,

                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 2,
                                                      ),
                                                      child: Text(
                                                        weightOptions[index],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // Price and Attribute
                                  Row(
                                    children: [
                                      Text(
                                        '₹${displayPrice.toStringAsFixed(2)}', // Show price based on selected attribute
                                        style: TextStyle(
                                          color: primarylogin,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 10,),


                                      // MRP (only if > 0 AND different from price)
                                      if (mrp != 0)
                                        Text(
                                          '₹${mrp.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),

                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Quantity and Add to Cart - FIXED RENDER FLOW
                                  Row(
                                    children: [
                                      // Quantity Selector - User Friendly Design
                                      Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Minus Button
                                            GestureDetector(
                                              onTap: () {
                                                if (currentQty > minQty) {
                                                  setState(() {
                                                    productQuantities[
                                                    product['id']] =
                                                        currentQty - 1;
                                                  });
                                                } else {
                                                  toastMsg('Minimum quantity is $minQty', false);}
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 25,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(20),
                                                    bottomLeft:
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: currentQty > minQty
                                                      ? primarylogin
                                                      : Colors.grey[400],
                                                ),
                                              ),
                                            ),

                                            // Quantity Display
                                            Container(
                                              width: 25,
                                              alignment: Alignment.center,
                                              child: Text(
                                                currentQty.toString(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),

                                            // Plus Button
                                            GestureDetector(
                                              onTap: () {
                                                if (currentQty < maxQty) {
                                                  setState(() {
                                                    productQuantities[
                                                    product['id']] =
                                                        currentQty + 1;
                                                  });
                                                } else {
                                                  toastMsg('Maximum quantity is $maxQty', false);
                                                }
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 25,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                  const BorderRadius.only(
                                                    topRight:
                                                    Radius.circular(20),
                                                    bottomRight:
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: currentQty < maxQty
                                                      ? primarylogin
                                                      : Colors.grey[400],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Add to Cart Button
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: stockStatus == 0
                                              ? null
                                              : () {
                                            final addtocartUrl = Uri.parse(addtocart_url);

                                            Map<String, dynamic> addtocartBody = {
                                              'product_id': product['id'].toString(),
                                              'quantity': productQuantities[product['id']].toString(),
                                              'session_id': Environment.deviceid.toString(),
                                            };

                                            // Sirf tab attribute_id bhejo jab is product ka attribute available hai
                                            final selectedAttributeId =
                                            selectedAttributeIds[product['id']];

                                            if (selectedAttributeId != null &&
                                                selectedAttributeId.isNotEmpty) {
                                              addtocartBody['attribute_id'] = selectedAttributeId;
                                            }

                                            log('Add To Cart Body: $addtocartBody');

                                            final addtocarttBody = jsonEncode(addtocartBody);

                                            addCartController.AddtoCartApi(
                                              addtocartUrl,
                                              addtocarttBody,
                                            );
                                          },
                                          child: Container(
                                            height: 25,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            decoration: BoxDecoration(
                                              gradient: stockStatus == 0
                                                  ? LinearGradient(colors: [Colors.grey, Colors.grey])
                                                  : LinearGradient(
                                                colors: [primary2, primary2.withOpacity(0.8)],
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                  stockStatus == 0?Colors.grey.withOpacity(0.3): primary2.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Add',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: productController.productListData.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void displayBottomSheet(
      BuildContext context,
      List<dynamic> categories,
      String name,
      Size size,
      ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        final selectedCategory = categories.firstWhere(
              (e) => e["id"].toString() == widget.catId.toString(),
          orElse: () => {},
        );

        final List subCategories = selectedCategory['sub_categories'] ?? [];
        log('sub cat>>>${selectedCategory['sub_categories']}');

        if (subCategories.isEmpty) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No subcategories found",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: size.height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primarylogin.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: primarylogin,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Subcategories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Subcategories List
              Expanded(
                child: ListView.builder(
                  itemCount: subCategories.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final sub = subCategories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.off(Product(
                          catId: sub["id"],
                          name: sub["name"],
                          CatData: categories,
                        ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                sub["image_url"] ?? "",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sub["name"] ?? "",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  callProductWishLiat(String areaId) async {

    productController.wishlistPage = 1;

    await productController.GetProductWishList(
      page: 1,
      limit: productController.wishlistLimit,
      areaId: areaId,
    );
  }
}