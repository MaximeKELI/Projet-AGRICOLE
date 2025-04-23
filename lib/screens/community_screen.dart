import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Comment utiliser la carte pour analyser mes champs ?',
      answer: '1. Dessinez un polygone autour de votre champ\n'
          '2. Utilisez le bouton NDVI pour voir l\'état de la végétation\n'
          '3. Consultez la météo locale avec le bouton nuage\n'
          '4. Comparez les différentes couches (couleur naturelle, NDVI, humidité)',
    ),
    FAQItem(
      question: 'Qu\'est-ce que l\'indice NDVI et comment l\'interpréter ?',
      answer: 'L\'indice NDVI (Normalized Difference Vegetation Index) mesure la santé de la végétation :\n\n'
          '- > 0.6 : Végétation très dense et saine\n'
          '- 0.3 à 0.6 : Végétation modérée\n'
          '- 0 à 0.3 : Végétation clairsemée\n'
          '- < 0 : Pas de végétation\n\n'
          'Utilisez cet indice pour détecter les zones stressées ou malades.',
    ),
    FAQItem(
      question: 'Comment optimiser l\'irrigation avec les données météo ?',
      answer: '1. Surveillez les prévisions de pluie\n'
          '2. Adaptez l\'irrigation selon l\'humidité du sol\n'
          '3. Évitez l\'irrigation pendant les périodes de forte chaleur\n'
          '4. Utilisez les données d\'évapotranspiration pour calculer les besoins en eau',
    ),
    FAQItem(
      question: 'Quelles sont les meilleures pratiques pour la gestion des cultures ?',
      answer: '1. Rotation des cultures pour maintenir la fertilité du sol\n'
          '2. Surveillance régulière des indices de végétation\n'
          '3. Adaptation des pratiques culturales selon les conditions météo\n'
          '4. Utilisation des données satellitaires pour la détection précoce des problèmes',
    ),
    FAQItem(
      question: 'Comment détecter les maladies des plantes ?',
      answer: '1. Surveillez les changements dans l\'indice NDVI\n'
          '2. Observez les variations de couleur sur les images satellites\n'
          '3. Comparez avec les données historiques\n'
          '4. Utilisez l\'analyse IA pour une détection précoce',
    ),
    FAQItem(
      question: 'Quelle est la fréquence de mise à jour des images satellites ?',
      answer: 'Les images Sentinel-2 sont mises à jour tous les 5 jours environ.\n'
          'La fréquence peut varier selon la couverture nuageuse.\n'
          'Les données météo sont mises à jour toutes les heures.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté & FAQ'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQCard(_faqs[index]);
        },
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
