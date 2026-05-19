import 'package:flutter/material.dart';

class AdditiveGuideScreen extends StatefulWidget {
  const AdditiveGuideScreen({super.key});

  @override
  State<AdditiveGuideScreen> createState() => _AdditiveGuideScreenState();
}

class _AdditiveGuideScreenState extends State<AdditiveGuideScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> additives = const [
    {
      'code': 'E102',
      'name': 'Tartrazin',
      'category': 'Renklendirici',
      'risk': 'Orta',
      'usage': 'Gıdalara sarı renk vermek için kullanılır.',
    },
    {
      'code': 'E110',
      'name': 'Sunset Yellow',
      'category': 'Renklendirici',
      'risk': 'Orta',
      'usage': 'Turuncu-sarı renk vermek için kullanılır.',
    },
    {
      'code': 'E124',
      'name': 'Ponceau 4R',
      'category': 'Renklendirici',
      'risk': 'Orta',
      'usage': 'Kırmızı renk vermek için kullanılır.',
    },
    {
      'code': 'E211',
      'name': 'Sodyum Benzoat',
      'category': 'Koruyucu',
      'risk': 'Orta',
      'usage': 'Mikroorganizmaların gelişimini engellemek için kullanılır.',
    },
    {
      'code': 'E250',
      'name': 'Sodyum Nitrit',
      'category': 'Koruyucu',
      'risk': 'Yüksek',
      'usage': 'Et ürünlerinde renk koruma ve mikrobiyal kontrol için kullanılır.',
    },
    {
      'code': 'E621',
      'name': 'Monosodyum Glutamat',
      'category': 'Tatlandırıcı / Aroma Verici',
      'risk': 'Orta',
      'usage': 'Umami tat vermek ve lezzet artırmak için kullanılır.',
    },
  ];

  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredAdditives {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) return additives;

    return additives.where((item) {
      return item['code']!.toLowerCase().contains(q) ||
          item['name']!.toLowerCase().contains(q) ||
          item['category']!.toLowerCase().contains(q) ||
          item['risk']!.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFC),
        elevation: 0,
        foregroundColor: const Color(0xFF4D7C57),
        title: const Text(
          'Katkı Maddeleri Rehberi',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const _HeroInfoCard(),
          const SizedBox(height: 16),

          _SearchBox(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Risk Seviyeleri Ne Anlama Gelir?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17213A),
            ),
          ),
          const SizedBox(height: 12),

          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RiskBox(
                  title: 'Düşük',
                  text: 'Genel olarak düşük dikkat gerektirir.',
                  color: Color(0xFF5DA96B),
                  icon: Icons.check_rounded,
                ),
                SizedBox(width: 12),
                _RiskBox(
                  title: 'Orta',
                  text: 'Hassas bireylerde dikkat gerektirebilir.',
                  color: Color(0xFFE2A53B),
                  icon: Icons.priority_high_rounded,
                ),
                SizedBox(width: 12),
                _RiskBox(
                  title: 'Yüksek',
                  text: 'Daha fazla dikkat gerektirebilir.',
                  color: Color(0xFFD95C5C),
                  icon: Icons.warning_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Sık Karşılaşılan Katkı Maddeleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17213A),
            ),
          ),
          const SizedBox(height: 12),

          if (filteredAdditives.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Aramana uygun katkı maddesi bulunamadı.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...filteredAdditives.map(
              (item) => _AdditiveCard(
                code: item['code']!,
                name: item['name']!,
                category: item['category']!,
                risk: item['risk']!,
                usage: item['usage']!,
              ),
            ),

          const SizedBox(height: 16),

          const _ReminderCard(),
          const SizedBox(height: 10),

          Text(
            'Kaynak yaklaşımı: DSÖ/FAO JECFA, katkı maddelerini kabul edilebilir günlük alım ve bilimsel değerlendirme çerçevesinde ele alır.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoCard extends StatelessWidget {
  const _HeroInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF4C7D2)),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.science_rounded,
              size: 52,
              color: Color(0xFFE8578A),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-kodları nasıl yorumlamalıyım?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8578A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Risk seviyesi; bilimsel veriler, kullanım miktarı ve hassas bireylerde dikkat gerektirme durumuna göre yorumlanır.',
                  style: TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'E-kod veya katkı maddesi ara...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _RiskBox extends StatelessWidget {
  final String title;
  final String text;
  final Color color;
  final IconData icon;

  const _RiskBox({
    required this.title,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _AdditiveCard extends StatelessWidget {
  final String code;
  final String name;
  final String category;
  final String risk;
  final String usage;

  const _AdditiveCard({
    required this.code,
    required this.name,
    required this.category,
    required this.risk,
    required this.usage,
  });

  Color get riskColor {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return const Color(0xFF5DA96B);
      case 'orta':
        return const Color(0xFFE2A53B);
      case 'yüksek':
        return const Color(0xFFD95C5C);
      default:
        return Colors.grey;
    }
  }

  Color get categoryColor {
    if (category.toLowerCase().contains('koruyucu')) {
      return const Color(0xFF5DA9E9);
    }
    if (category.toLowerCase().contains('tatlandırıcı')) {
      return const Color(0xFF78B77D);
    }
    return const Color(0xFFE2A53B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF17213A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(text: category, color: categoryColor),
              _MiniBadge(text: risk, color: riskColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            usage,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

 

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
  text,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    color: color,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  ),
),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4C7D2)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: Color(0xFFE8578A),
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bu bilgiler tanı veya tedavi önerisi değildir. Hassasiyet, alerji veya özel sağlık durumlarında uzman görüşü alınmalıdır.',
              style: TextStyle(height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}