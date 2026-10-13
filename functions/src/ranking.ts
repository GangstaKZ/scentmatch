export interface Fragrance {
  id: string; name: string; brand: string; family: string; gender: string;
  priceRange: string; longevity: number; season: string[];
}
export interface Match { perfumeId: string; score: number; reason: string }
export function rank(catalog: Fragrance[], quiz: Record<string, string>): Match[] {
  return catalog.map(p => {
    let score = p.family === quiz.family ? 35 : 0;
    if (p.gender === quiz.gender || p.gender === 'unisex' || quiz.gender === 'any') score += 15;
    if (p.priceRange === quiz.budget) score += 20;
    if (p.season.includes(quiz.season)) score += 15;
    if ((p.longevity >= 8 ? 'long' : p.longevity >= 4 ? 'medium' : 'light') === quiz.longevity) score += 10;
    if ((quiz.mood === 'bold' && ['woody', 'amber'].includes(p.family)) ||
        (quiz.mood === 'romantic' && p.family === 'floral') ||
        (quiz.mood === 'calm' && p.family === 'fresh') || ['day', 'evening'].includes(quiz.mood)) score += 5;
    return {perfumeId: p.id, score, reason: 'local'};
  }).sort((a, b) => b.score - a.score || (a.perfumeId < b.perfumeId ? -1 : a.perfumeId > b.perfumeId ? 1 : 0)).slice(0, 6);
}
