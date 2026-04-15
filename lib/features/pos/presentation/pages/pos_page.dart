import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../inventory/presentation/logic/inventory_cubit.dart';
import '../../../inventory/presentation/logic/inventory_state.dart';
import '../logic/cart_cubit.dart';
import '../logic/cart_state.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Items';

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1100;
    final isTablet = size.width > 700 && size.width <= 1100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state.isSuccess) {
          MotionToast.success(
            title: const Text('Sale Completed',
                style: TextStyle(fontWeight: FontWeight.bold)),
            description:
                const Text('Local stock updated. Syncing in background.'),
            toastAlignment: Alignment.topCenter,
            animationType: AnimationType.slideInFromTop,
          ).show(context);
        } else if (state.errorMessage != null) {
          MotionToast.error(
            title: const Text('Error',
                style: TextStyle(fontWeight: FontWeight.bold)),
            description: Text(state.errorMessage!),
            toastAlignment: Alignment.topCenter,
          ).show(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            if (isDesktop || isTablet) const _SideNav(),
            Expanded(
              flex: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 25),
                    _buildSearchAndFilterSection(context, isDark),
                    const SizedBox(height: 25),
                    Expanded(child: _buildInventoryGrid(isDesktop, isDark)),
                  ],
                ),
              ),
            ),
            if (isDesktop) const _RightSidebar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GOOD EVENING, DR. SHARMA',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: AppTheme.darkTextGrey)),
            const SizedBox(height: 5),
            Text('POS Billing',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                  context.watch<ThemeCubit>().state == ThemeMode.dark
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_outlined,
                  color: Colors.grey),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
            IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.grey),
                onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? null : Border.all(color: Colors.grey[300]!)),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => context.read<InventoryCubit>().searchProduct(v),
            decoration: InputDecoration(
              hintText: 'Search products, brands, or batches...',
              hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkTextGrey : Colors.grey),
              prefixIcon: Icon(Icons.search,
                  color: isDark ? AppTheme.darkTextGrey : Colors.grey),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _filterChip('All Items', isDark),
              _filterChip('Antibiotics', isDark),
              _filterChip('Syrups', isDark),
              _filterChip('Injections', isDark),
              const Spacer(),
              BlocBuilder<InventoryCubit, InventoryState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is InventoryLoaded) count = state.products.length;
                  return Text('$count Results',
                      style: TextStyle(
                          color: isDark ? AppTheme.darkTextGrey : Colors.grey,
                          fontSize: 12));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isDark) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.grey[800] : Colors.blue[100])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.blue)
                    : (isDark ? AppTheme.darkTextGrey : Colors.grey),
                fontSize: 12)),
      ),
    );
  }

  Widget _buildInventoryGrid(bool isDesktop, bool isDark) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InventoryLoaded) {
          if (state.products.isEmpty) {
            return const Center(
                child: Text('No medicines found',
                    style: TextStyle(color: Colors.grey)));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.6,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkProductCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: product.stockQuantity < 10
                          ? Colors.red.withValues(alpha: 0.5)
                          : (isDark ? Colors.grey[900]! : Colors.grey[200]!)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<CartCubit>().addToCart(product),
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(product.name,
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text('${product.stockQuantity}',
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.grey
                                            : Colors.grey[700],
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                          Text(product.genericName ?? 'Labs',
                              style: TextStyle(
                                  color: isDark
                                      ? AppTheme.darkTextGrey
                                      : Colors.grey[600],
                                  fontSize: 12)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product.id.toString(),
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[900]
                                          : Colors.grey[300],
                                      fontSize: 10)),
                              Text('৳${product.price}',
                                  style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text('Failed to load inventory'));
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 250,
      color: isDark ? AppTheme.darkSidebarBg : Colors.white,
      decoration: isDark
          ? null
          : BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[200]!))),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildBrand(isDark),
          const SizedBox(height: 40),
          _navItem(Icons.grid_view, 'Dashboard', false, isDark),
          _navItem(Icons.shopping_cart_outlined, 'POS Billing', true, isDark,
              hasNotification: true),
          _navItem(Icons.inventory_2_outlined, 'Inventory', false, isDark),
          _navItem(Icons.local_shipping_outlined, 'Suppliers', false, isDark),
          _navItem(Icons.people_outline, 'Customers', false, isDark),
          _navItem(Icons.history_outlined, 'Purchases', false, isDark),
          _navItem(Icons.receipt_outlined, 'Invoices', false, isDark),
          _navItem(Icons.bar_chart_outlined, 'Reports', false, isDark),
          const Spacer(),
          _buildSystemStatus(isDark),
          const SizedBox(height: 10),
          _navItem(Icons.logout, 'LOGOUT', false, isDark, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBrand(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.link,
                color: isDark ? Colors.black : Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ABIR',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text('PHARMACEUTICALS',
                  style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 9,
                      letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, bool isSelected, bool isDark,
      {bool hasNotification = false, bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? const Color(0xFF1E1E1E)
                : Colors.blue.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected && isDark ? Border.all(color: Colors.grey[800]!) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isLogout
                ? Colors.red
                : (isSelected
                    ? (isDark ? Colors.white : Colors.blue)
                    : Colors.grey[600]),
            size: 20),
        title: Text(title,
            style: TextStyle(
                color: isLogout
                    ? Colors.red
                    : (isSelected
                        ? (isDark ? Colors.white : Colors.blue)
                        : Colors.grey[600]),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: hasNotification
            ? Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle))
            : null,
        onTap: () {},
      ),
    );
  }

  Widget _buildSystemStatus(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYSTEM ONLINE',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              Text('v2.0.5 • STABLE',
                  style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RightSidebar extends StatelessWidget {
  const _RightSidebar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 380,
      color: isDark ? AppTheme.darkSidebarBg : Colors.white,
      decoration: isDark
          ? null
          : BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey[200]!))),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Bill',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${state.items.length} items',
                      style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey[700],
                          fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSegmentTab(isDark),
          const SizedBox(height: 15),
          _buildCustomerSearch(isDark),
          const SizedBox(height: 20),
          Expanded(child: _buildCartList(isDark)),
          Divider(color: isDark ? const Color(0xFF222222) : Colors.grey[200]),
          _buildPaymentSelection(isDark),
          const SizedBox(height: 20),
          _buildBillSummary(isDark),
          const SizedBox(height: 20),
          _buildGenerateInvoiceButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: _tabItem('CUSTOMER', true, isDark)),
          Expanded(child: _tabItem('SUPPLIER', false, isDark)),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF252525) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive && !isDark
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4)
                ]
              : null),
      child: Center(
          child: Text(label,
              style: TextStyle(
                  color: isActive
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildCustomerSearch(bool isDark) {
    return TextField(
      style:
          TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search Customer...',
        hintStyle: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey),
        prefixIcon: Icon(Icons.person_search_outlined,
            color: isDark ? Colors.grey[700] : Colors.grey, size: 18),
        filled: true,
        fillColor: Colors.transparent,
        border: UnderlineInputBorder(
            borderSide: BorderSide(
                color: isDark ? Colors.grey[900]! : Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildCartList(bool isDark) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_basket_outlined,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    size: 40),
                const SizedBox(height: 10),
                Text('Cart is empty',
                    style: TextStyle(
                        color: isDark ? Colors.grey[800] : Colors.grey[400])),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text('৳${item.product.price} x ${item.quantity}',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[600],
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                      '৳${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red, size: 18),
                    onPressed: () => context
                        .read<CartCubit>()
                        .updateQuantity(item.product.id, item.quantity - 1),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentSelection(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _payBtn(Icons.payments_outlined, 'Cash', true, isDark),
        _payBtn(Icons.account_balance_wallet_outlined, 'Cheque', false, isDark),
        _payBtn(Icons.qr_code_scanner, 'UPI', false, isDark),
        _payBtn(Icons.schedule_outlined, 'Pay Later', false, isDark),
      ],
    );
  }

  Widget _payBtn(IconData icon, String label, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? const Color(0xFF1A1A1A) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon,
              color: isActive
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.grey[600] : Colors.grey[600]),
              size: 20),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey[600] : Colors.grey[600]),
                fontSize: 10)),
      ],
    );
  }

  Widget _buildBillSummary(bool isDark) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            _summaryRow(
                'Subtotal', '৳${state.totalAmount.toStringAsFixed(2)}', isDark),
            _summaryRow('GST Total', '৳0.00', isDark),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('৳${state.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[600],
                  fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGenerateInvoiceButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => context.read<CartCubit>().checkout(),
        icon: const Icon(Icons.print_outlined),
        label: const Text('Generate Invoice',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
