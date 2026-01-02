import 'package:flutter/material.dart';

import '../../payments/models/payment_performance_model.dart';
import '../../payments/services/payments_service.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/page_x.dart';
import '../../shared/widgets/toast_x.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import 'payment_performance_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _dashboardService = DashboardService();
  DashboardModel? _dashboard;
  bool _isLoading = false;

  // Performance Chart
  List<PaymentPerformanceModel> _performanceData = [];
  bool _isLoadingPerformance = false;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadPaymentPerformance();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    final response = await _dashboardService.getDashboard();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.statusCode == 200 && response.data != null) {
      setState(() => _dashboard = response.data);
    } else {
      if (mounted) {
        ToastX.error(context, response.message ?? 'Failed to load dashboard');
      }
    }
  }

  Future<void> _loadPaymentPerformance() async {
    setState(() => _isLoadingPerformance = true);

    final response = await PaymentsService.getPaymentPerformance(
      days: _selectedDays,
    );

    if (!mounted) return;

    setState(() => _isLoadingPerformance = false);

    if (response.statusCode == 200 && response.data != null) {
      setState(() => _performanceData = response.data!);
    } else {
      if (mounted) {
        ToastX.error(context, response.message ?? 'Failed to load performance');
      }
    }
  }

  void _onPeriodSelected(int days) {
    setState(() => _selectedDays = days);
    _loadPaymentPerformance();
  }

  @override
  Widget build(BuildContext context) {
    return PageX(
      title: 'Dashboard',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboard == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load dashboard'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // Performance & Transactions (2 columns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Performance Chart (Left Column)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionTitle('Performance'),
                              const SizedBox(height: 12),
                              _buildPaymentPerformanceSection(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Transactions (Right Column)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionTitle('Transactions'),
                              const SizedBox(height: 12),
                              _buildTransactionsStats(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildSummaryCard(
          'Tenants',
          _dashboard!.totalTenants.toString(),
          Icons.business,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Branches',
          _dashboard!.totalBranches.toString(),
          Icons.store,
          Colors.green,
        ),
        _buildSummaryCard(
          'Users',
          _dashboard!.totalUsers.toString(),
          Icons.people,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Products',
          _dashboard!.totalProducts.toString(),
          Icons.shopping_bag,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPaymentPerformanceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selection Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeriodButton('7 Days', 7),
                _buildPeriodButton('1 Month', 30),
                _buildPeriodButton('3 Months', 90),
                _buildPeriodButton('6 Months', 180),
                _buildPeriodButton('1 Year', 365),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            _isLoadingPerformance
                ? const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : PaymentPerformanceChart(data: _performanceData),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return ElevatedButton(
      onPressed: () => _onPeriodSelected(days),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildTransactionsStats() {
    final transactions = _dashboard!.transactions;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              'Today',
              CurrencyFormatter.format(transactions.today),
            ),
            const Divider(),
            _buildStatRow(
              'This Week',
              CurrencyFormatter.format(transactions.thisWeek),
            ),
            const Divider(),
            _buildStatRow(
              'This Month',
              CurrencyFormatter.format(transactions.thisMonth),
            ),
            const Divider(),
            _buildStatRow(
              'Last 7 Days',
              CurrencyFormatter.format(transactions.last7Days),
            ),
            const Divider(),
            _buildStatRow(
              'Last 30 Days',
              CurrencyFormatter.format(transactions.last30Days),
            ),
            const Divider(),
            _buildStatRow(
              'Last 90 Days',
              CurrencyFormatter.format(transactions.last90Days),
            ),
            const Divider(),
            _buildStatRow(
              'Last 180 Days',
              CurrencyFormatter.format(transactions.last180Days),
            ),
            const Divider(),
            _buildStatRow(
              'Last 360 Days',
              CurrencyFormatter.format(transactions.last360Days),
            ),
            const Divider(),
            _buildStatRow(
              'All Time',
              CurrencyFormatter.format(transactions.allTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
