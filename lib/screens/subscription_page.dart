import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../config/theme.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium-tilaus'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium badge if subscribed
            if (subscriptionProvider.isPremium) ...[
              Card(
                color: AppTheme.primaryRed,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Premium-jäsen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (subscriptionProvider.subscriptionEndDate != null)
                              Text(
                                'Voimassa: ${_formatDate(subscriptionProvider.subscriptionEndDate!)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Features
            Text(
              'Premium-jäsenyys',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryRed, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star,
                    size: 64,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Koko sovellus käytössäsi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium-jäsenyydellä saat koko sovelluksen käyttöösi:\n\n'
                    '✓ Kirjaa matkat ja kulut\n'
                    '✓ Seuraa tilastoja\n'
                    '✓ Lisää useita ajoneuvoja\n'
                    '✓ Lisää muistutuksia\n'
                    '✓ Tallenna kuitit\n'
                    '✓ Vie tiedot\n'
                    '✓ Kaikki tulevat ominaisuudet',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ilmaisen kokeilujakson jälkeen matkojen kirjaus vaatii Premium-tilauksen. '
                      'Voit kuitenkin tallentaa ja viedä tietosi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription plans
            if (!subscriptionProvider.isPremium) ...[
              Text(
                'Valitse tilaus',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              
              // Free trial banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryRed, AppTheme.primaryRed.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ilmainen 30 päivän kokeilu!\nKokeile kaikkia ominaisuuksia',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subscription products
              if (subscriptionProvider.products.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...subscriptionProvider.products.map((product) {
                  final isYearly = product.id == SubscriptionProvider.yearlySubscriptionId;
                  return _SubscriptionCard(
                    title: isYearly ? 'Vuositilaus' : 'Kuukausitilaus',
                    price: product.price,
                    period: isYearly ? 'vuosi' : 'kuukausi',
                    savings: isYearly ? 'Säästä 20%!' : null,
                    isPopular: isYearly,
                    onTap: () async {
                      final success = await subscriptionProvider.buySubscription(product);
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tilaus aloitettu!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tilaus epäonnistui')),
                          );
                        }
                      }
                    },
                  );
                }),
              
              const SizedBox(height: 16),
              
              // Restore purchases button
              Center(
                child: TextButton(
                  onPressed: () async {
                    await subscriptionProvider.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ostokset palautettu')),
                      );
                    }
                  },
                  child: const Text('Palauta ostokset'),
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            // Terms
            const Text(
              'Tilaus uusiutuu automaattisesti. Voit peruuttaa tilauksen milloin tahansa asetuksista. '
              'Ehdot ja käyttöoikeudet määräytyvät App Storen tai Google Play Storen sääntöjen mukaan.',
              style: TextStyle(fontSize: 12, color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isPopular;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isPopular ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular
            ? const BorderSide(color: AppTheme.primaryRed, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (savings != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        savings!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: price,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    TextSpan(
                      text: ' / $period',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? AppTheme.primaryRed : AppTheme.mediumGray,
                  ),
                  child: const Text('Aloita tilaus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
