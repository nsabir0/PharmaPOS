import 'package:motion_toast/motion_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_pos/features/inventory/presentation/logic/inventory_cubit.dart';
import 'package:pharma_pos/features/inventory/presentation/logic/inventory_state.dart';
import 'package:pharma_pos/features/pos/presentation/logic/cart_cubit.dart';
import 'package:pharma_pos/features/pos/presentation/logic/cart_state.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state.isSuccess) {
          MotionToast.success(
            title: const Text('Sale Completed', style: TextStyle(fontWeight: FontWeight.bold)),
            description: const Text('Local stock updated. Syncing in background.'),
            toastAlignment: Alignment.topCenter,
            animationType: AnimationType.slideInFromTop,
          ).show(context);
        } else if (state.errorMessage != null) {
          MotionToast.error(
            title: const Text('Sale Failed', style: TextStyle(fontWeight: FontWeight.bold)),
            description: Text(state.errorMessage!),
            toastAlignment: Alignment.topCenter,
            animationType: AnimationType.slideInFromTop,
          ).show(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/pharmapos_logo.png', height: 40),
              const SizedBox(width: 10),
              const Text('PharmaPOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => context.read<InventoryCubit>().fetchInventory(),
            ),
          ],
        ),
        body: Row(
          children: [
            // Left Side: Product List & Search
            Expanded(
              flex: isDesktop ? 2 : 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Medicine or Generic...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<InventoryCubit>().searchProduct('');
                          },
                        ),
                      ),
                      onChanged: (value) {
                        context.read<InventoryCubit>().searchProduct(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<InventoryCubit, InventoryState>(
                      builder: (context, state) {
                        if (state is InventoryLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is InventoryLoaded) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 4 : 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return Card(
                                color: product.stockQuantity <= 5 ? Colors.red[50] : null,
                                child: InkWell(
                                  onTap: () {
                                    if (product.stockQuantity > 0) {
                                      context.read<CartCubit>().addToCart(product);
                                    } else {
                                      MotionToast.warning(
                                        title: const Text('Out of Stock'),
                                        description: const Text('This product is currently unavailable.'),
                                      ).show(context);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(product.genericName ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        const Spacer(),
                                        Text('৳${product.price}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Stock: ${product.stockQuantity}', 
                                                style: TextStyle(fontSize: 10, color: product.stockQuantity <= 5 ? Colors.red : Colors.black54)),
                                            if (product.stockQuantity <= 5)
                                              const Icon(Icons.warning, size: 12, color: Colors.red),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text('Error loading products'));
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Right Side: Billing Cart
            if (isDesktop)
              VerticalDivider(width: 1, color: Colors.grey[300]),
            if (isDesktop)
              SizedBox(
                width: 400,
                child: _CartPanel(),
              ),
          ],
        ),
        floatingActionButton: !isDesktop
            ? FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.8, child: _CartPanel()),
                  );
                },
                label: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) => Text('Cart (${state.items.length}) - ৳${state.totalAmount}'),
                ),
                icon: const Icon(Icons.shopping_cart),
              )
            : null,
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Billing Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: state.items.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 50, color: Colors.grey),
                        Text('Your cart is empty', style: TextStyle(color: Colors.grey)),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return ListTile(
                          title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('৳${item.product.price} x ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                onPressed: () => context.read<CartCubit>().updateQuantity(item.product.id, item.quantity - 1),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => context.read<CartCubit>().updateQuantity(item.product.id, item.quantity + 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                border: const Border(top: BorderSide(color: Colors.blue, width: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payable:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('৳${state.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      onPressed: state.items.isEmpty || state.isSubmitting ? null : () => context.read<CartCubit>().checkout(),
                      child: state.isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                SizedBox(width: 10),
                                Text('Processing Sale...'),
                              ],
                            )
                          : const Text('COMPLETE SALE (F12)', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
