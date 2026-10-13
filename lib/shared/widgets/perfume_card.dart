import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/catalog/domain/perfume.dart';
import '../../core/localization/app_strings.dart';

/// Original bottle illustrations avoid depending on unlicensed product images.
/// Set imageUrl to a licensed Firebase Storage URL to show a real packshot.
class BottleArt extends StatelessWidget {
  const BottleArt({super.key, required this.perfume, this.height = 160});
  final Perfume perfume;
  final double height;
  @override
  Widget build(BuildContext context) {
    final color = Color(perfume.color);
    final art = Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
                center: const Alignment(.25, -.2),
                radius: 1.1,
                colors: [color.withOpacity(.3), color.withOpacity(.04)])),
        child: Center(
            child: Semantics(
                label: context.tr('Иллюстрация флакона', 'Bottle illustration'),
                child: SizedBox(
                    width: height * .57,
                    height: height * .83,
                    child: Stack(alignment: Alignment.center, children: [
                      Positioned(
                          top: 4,
                          child: Container(
                              width: height * .23,
                              height: height * .16,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF292C26),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white24)))),
                      Positioned(
                          top: height * .18,
                          bottom: 7,
                          left: 6,
                          right: 6,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(.35),
                                      width: 1.5),
                                  gradient: LinearGradient(colors: [
                                    color.withOpacity(.8),
                                    color.withOpacity(.35),
                                    color.withOpacity(.65)
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.22),
                                        blurRadius: 16,
                                        offset: const Offset(0, 12))
                                  ]),
                              child: Center(
                                  child: Container(
                                      margin: EdgeInsets.all(height * .045),
                                      padding: EdgeInsets.symmetric(
                                          vertical: height * .045,
                                          horizontal: 3),
                                      color: const Color(0xFFF1EBDA),
                                      width: double.infinity,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(perfume.brand.toUpperCase(),
                                                style: TextStyle(
                                                    color:
                                                        const Color(0xFF343C32),
                                                    fontSize: height * .038,
                                                    letterSpacing: 1),
                                                maxLines: 2,
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 5),
                                            Text(perfume.name,
                                                style: TextStyle(
                                                    color:
                                                        const Color(0xFF343C32),
                                                    fontSize: height * .046,
                                                    fontFamily:
                                                        'CormorantGaramond'),
                                                maxLines: 2,
                                                textAlign: TextAlign.center),
                                          ]))))),
                    ])))));
    if (perfume.imageUrl.isEmpty) return art;
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(perfume.imageUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => art,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : art));
  }
}

class PerfumeCard extends StatelessWidget {
  const PerfumeCard({super.key, required this.perfume, this.score});
  final Perfume perfume;
  final int? score;
  @override
  Widget build(BuildContext context) => Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
          onTap: () => context.push('/perfume/${perfume.id}',
              extra:
                  'bottle_${perfume.id}_${score == null ? 'catalog' : 'match'}'),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      Hero(
                          tag:
                              'bottle_${perfume.id}_${score == null ? 'catalog' : 'match'}',
                          child: BottleArt(perfume: perfume, height: 152)),
                      if (score != null)
                        Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text('$score%',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary))))
                    ]),
                    const SizedBox(height: 12),
                    Text(perfume.brand.toUpperCase(),
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.4,
                            color: Theme.of(context).colorScheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text(perfume.name,
                        style: const TextStyle(
                            fontFamily: 'CormorantGaramond', fontSize: 19),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Text(
                        '${context.label(perfume.family)} · ${context.label(perfume.gender)}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]))));
}

class PerfumeGrid extends StatelessWidget {
  const PerfumeGrid(
      {super.key, required this.perfumes, this.scores = const {}});
  final List<Perfume> perfumes;
  final Map<String, int> scores;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth >= 760
            ? 4
            : constraints.maxWidth >= 560
                ? 3
                : constraints.maxWidth < 300
                    ? 1
                    : 2;
        final width = (constraints.maxWidth - 12 * (count - 1)) / count;
        // Wrap allows cards to grow for translated copy and large text sizes.
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: perfumes
                .map((p) => SizedBox(
                    width: width,
                    child: PerfumeCard(perfume: p, score: scores[p.id])))
                .toList());
      });
}
