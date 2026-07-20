import '../../domain/enums.dart';

/// Starter ingredient library so tagging works from the first meal. Grows as
/// the user logs new ingredients. Tags follow Monash-style FODMAP groupings
/// at typical portions; users can edit any ingredient's tags.
class SeedIngredient {
  const SeedIngredient(this.name, this.tags);

  final String name;
  final Set<TriggerTag> tags;
}

const List<SeedIngredient> seedIngredients = [
  // Alliums & vegetables
  SeedIngredient('Onion', {TriggerTag.fructan}),
  SeedIngredient('Garlic', {TriggerTag.fructan}),
  SeedIngredient('Leek', {TriggerTag.fructan}),
  SeedIngredient('Shallot', {TriggerTag.fructan}),
  SeedIngredient('Cauliflower', {TriggerTag.polyol}),
  SeedIngredient('Mushroom', {TriggerTag.polyol}),
  SeedIngredient('Asparagus', {TriggerTag.fructan, TriggerTag.fructose}),
  SeedIngredient('Broccoli', {}),
  SeedIngredient('Spinach', {}),
  SeedIngredient('Carrot', {}),
  SeedIngredient('Potato', {}),
  SeedIngredient('Sweet potato', {TriggerTag.polyol}),
  SeedIngredient('Tomato', {}),
  SeedIngredient('Bell pepper', {}),
  SeedIngredient('Cucumber', {}),
  SeedIngredient('Lettuce', {}),
  SeedIngredient('Avocado', {TriggerTag.polyol}),

  // Grains & wheat
  SeedIngredient('Wheat bread', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('Pasta', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('Flour tortilla', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('Pizza dough', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('Barley', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('Rye bread', {TriggerTag.fructan, TriggerTag.gluten}),
  SeedIngredient('White rice', {}),
  SeedIngredient('Oats', {}),
  SeedIngredient('Corn tortilla', {}),
  SeedIngredient('Quinoa', {}),

  // Dairy
  SeedIngredient('Milk', {TriggerTag.lactose, TriggerTag.dairy}),
  SeedIngredient('Ice cream', {TriggerTag.lactose, TriggerTag.dairy, TriggerTag.highFat}),
  SeedIngredient('Soft cheese', {TriggerTag.lactose, TriggerTag.dairy}),
  SeedIngredient('Hard cheese', {TriggerTag.dairy}),
  SeedIngredient('Aged cheese', {TriggerTag.dairy, TriggerTag.histamine}),
  SeedIngredient('Yogurt', {TriggerTag.lactose, TriggerTag.dairy}),
  SeedIngredient('Butter', {TriggerTag.dairy, TriggerTag.highFat}),
  SeedIngredient('Cream', {TriggerTag.lactose, TriggerTag.dairy, TriggerTag.highFat}),
  SeedIngredient('Cream sauce', {TriggerTag.lactose, TriggerTag.dairy, TriggerTag.highFat}),

  // Protein
  SeedIngredient('Chicken breast', {}),
  SeedIngredient('Eggs', {}),
  SeedIngredient('Beef', {}),
  SeedIngredient('Fatty beef (ribeye, burger)', {TriggerTag.highFat}),
  SeedIngredient('Pork', {}),
  SeedIngredient('Bacon', {TriggerTag.highFat, TriggerTag.histamine}),
  SeedIngredient('Cured meats (salami, prosciutto)',
      {TriggerTag.histamine, TriggerTag.highFat}),
  SeedIngredient('White fish', {}),
  SeedIngredient('Salmon', {}),
  SeedIngredient('Canned tuna', {TriggerTag.histamine}),
  SeedIngredient('Shellfish', {TriggerTag.histamine}),
  SeedIngredient('Tofu (firm)', {}),

  // Legumes & nuts
  SeedIngredient('Black beans', {TriggerTag.gos}),
  SeedIngredient('Chickpeas', {TriggerTag.gos}),
  SeedIngredient('Lentils', {TriggerTag.gos}),
  SeedIngredient('Cashews', {TriggerTag.gos}),
  SeedIngredient('Pistachios', {TriggerTag.gos, TriggerTag.fructan}),
  SeedIngredient('Almonds', {}),
  SeedIngredient('Peanuts', {}),
  SeedIngredient('Peanut butter', {TriggerTag.highFat}),

  // Fruit
  SeedIngredient('Apple', {TriggerTag.fructose, TriggerTag.polyol}),
  SeedIngredient('Pear', {TriggerTag.fructose, TriggerTag.polyol}),
  SeedIngredient('Watermelon', {TriggerTag.fructose, TriggerTag.polyol}),
  SeedIngredient('Mango', {TriggerTag.fructose}),
  SeedIngredient('Cherries', {TriggerTag.fructose, TriggerTag.polyol}),
  SeedIngredient('Peach', {TriggerTag.polyol}),
  SeedIngredient('Banana', {}),
  SeedIngredient('Blueberries', {}),
  SeedIngredient('Strawberries', {}),
  SeedIngredient('Orange', {}),
  SeedIngredient('Grapes', {}),

  // Sweeteners & condiments
  SeedIngredient('Honey', {TriggerTag.fructose}),
  SeedIngredient('High-fructose corn syrup', {TriggerTag.fructose}),
  SeedIngredient('Sugar-free gum/candy (sorbitol)',
      {TriggerTag.polyol, TriggerTag.artificialSweetener}),
  SeedIngredient('Diet soda', {TriggerTag.artificialSweetener, TriggerTag.caffeine}),
  SeedIngredient('Ketchup', {TriggerTag.fructose}),
  SeedIngredient('Soy sauce', {TriggerTag.histamine}),
  SeedIngredient('Vinegar', {TriggerTag.histamine}),
  SeedIngredient('Hot sauce', {TriggerTag.spicy}),
  SeedIngredient('Chili / chili flakes', {TriggerTag.spicy}),
  SeedIngredient('Curry (spicy)', {TriggerTag.spicy}),

  // Drinks
  SeedIngredient('Coffee', {TriggerTag.caffeine}),
  SeedIngredient('Espresso', {TriggerTag.caffeine}),
  SeedIngredient('Black tea', {TriggerTag.caffeine}),
  SeedIngredient('Energy drink', {TriggerTag.caffeine, TriggerTag.artificialSweetener}),
  SeedIngredient('Beer', {TriggerTag.alcohol, TriggerTag.gluten, TriggerTag.histamine}),
  SeedIngredient('Red wine', {TriggerTag.alcohol, TriggerTag.histamine}),
  SeedIngredient('White wine', {TriggerTag.alcohol, TriggerTag.histamine}),
  SeedIngredient('Spirits', {TriggerTag.alcohol}),
  SeedIngredient('Kombucha', {TriggerTag.histamine}),

  // Fats & fried
  SeedIngredient('Fried food', {TriggerTag.highFat}),
  SeedIngredient('French fries', {TriggerTag.highFat}),
  SeedIngredient('Olive oil', {}),
  SeedIngredient('Mayonnaise', {TriggerTag.highFat}),

  // Fermented
  SeedIngredient('Sauerkraut', {TriggerTag.histamine}),
  SeedIngredient('Kimchi', {TriggerTag.histamine, TriggerTag.spicy}),
  SeedIngredient('Chocolate', {TriggerTag.caffeine, TriggerTag.highFat}),
];
