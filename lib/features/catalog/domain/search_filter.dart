import 'perfume.dart';

class SearchFilter {
  const SearchFilter(
      {this.query = '',
      this.family = 'all',
      this.brand = 'all',
      this.gender = 'all',
      this.priceRange = 'all'});
  final String query, family, brand, gender, priceRange;
  bool matches(Perfume p) {
    final search = query.trim().toLowerCase();
    return '${p.name} ${p.brand}'.toLowerCase().contains(search) &&
        (family == 'all' || p.family == family) &&
        (brand == 'all' || p.brand == brand) &&
        (gender == 'all' || p.gender == gender) &&
        (priceRange == 'all' || p.priceRange == priceRange);
  }
}
