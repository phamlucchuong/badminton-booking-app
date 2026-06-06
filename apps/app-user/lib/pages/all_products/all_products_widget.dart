import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/models/product.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'all_products_model.dart';
export 'all_products_model.dart';

class AllProductsWidget extends StatefulWidget {
  const AllProductsWidget({
    super.key,
    this.courtId,
  });

  final String? courtId;

  static String routeName = 'AllProducts';
  static String routePath = '/allProducts';

  @override
  State<AllProductsWidget> createState() => _AllProductsWidgetState();
}

class _AllProductsWidgetState extends State<AllProductsWidget> {
  late AllProductsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllProductsModel());
    _productsFuture = FFAppState().venueRepository.getProducts(widget.courtId ?? '');
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(
                  CourtDetailsWidget.routeName,
                  queryParameters: {
                    'courtId': serializeParam(
                      widget.courtId,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              }
            },
          ),
          title: Text(
            context.l10n('Equipment & Rentals', 'Dụng cụ & Cho thuê'),
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          context.l10n('Failed to load products', 'Tải danh sách sản phẩm thất bại'),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data!;
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          context.l10n('No items available', 'Không có sản phẩm nào khả dụng'),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final formattedPrice = '${product.price.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: CachedNetworkImage(
                                        fadeInDuration: const Duration(milliseconds: 0),
                                        fadeOutDuration: const Duration(milliseconds: 0),
                                        imageUrl: product.imageId.isNotEmpty
                                            ? product.imageId
                                            : 'https://dimg.dreamflow.cloud/v1/image/professional%20badminton%20racket',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).labelLarge.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: FlutterFlowTheme.of(context).primaryText,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        formattedPrice,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        final cartList = List<Map<String, dynamic>>.from(
                                          FFAppState().cartAddons.map((e) => Map<String, dynamic>.from(e as Map)),
                                        );
                                        final existingIndex = cartList.indexWhere(
                                          (element) => element['productId'] == product.id,
                                        );

                                        if (existingIndex != -1) {
                                          final currentQty = cartList[existingIndex]['quantity'] as int? ?? 0;
                                          cartList[existingIndex]['quantity'] = currentQty + 1;
                                        } else {
                                          cartList.add({
                                            'productId': product.id,
                                            'name': product.name,
                                            'price': product.price,
                                            'quantity': 1,
                                            'imageId': product.imageId,
                                          });
                                        }

                                        FFAppState().update(() {
                                          FFAppState().cartAddons = cartList;
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.l10n(
                                                'Added ${product.name} to cart',
                                                'Đã thêm ${product.name} vào giỏ hàng',
                                              ),
                                            ),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          borderRadius: BorderRadius.circular(9999.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.add_rounded,
                                            color: FlutterFlowTheme.of(context).onPrimary,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
