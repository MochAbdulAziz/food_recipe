import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());

  void loadData() async {
    try {
      emit(HomeLoading());
      await Future.delayed(const Duration(seconds: 1));

      final categories = [
        const CategoryData(title: "Soup", icon: Icons.restaurant_menu),
        const CategoryData(title: "Breakfast", icon: Icons.bakery_dining),
        const CategoryData(title: "Drinks", icon: Icons.local_cafe_rounded),
        const CategoryData(title: "Dinner", icon: Icons.dinner_dining),
        const CategoryData(title: "More", icon: Icons.grid_view),
      ];

      final foodItems = [
        const FoodItemData(
          title: "Hot & Spicy Shrimp Rice",
          description: "Spicy fried rice with juicy shrimp and bold flavors in every bite.",
          rating: 5.0,
          imageUrl: "https://images.unsplash.com/photo-1552590635-27c2c2128abf?w=1000&auto=format&fit=crop&q=80",
          category: "Dinner",
          prepTime: "20 Min",
          calories: "480 kcal",
          servings: "2",
          proteins: "28 g",
          fats: "14 g",
          carbs: "62 g",
          ingredients: ['Shrimp', 'Jasmine Rice', 'Chili Oil', 'Garlic', 'Spring Onion'],
          steps: [
            RecipeStep(title: 'Cook the rice', description: 'Rinse jasmine rice until the water runs clear. Cook at 1:1.5 ratio with water — bring to boil, then 12 min on low. Spread flat to cool completely.', duration: '15 min'),
            RecipeStep(title: 'Prep the shrimp', description: 'Peel and devein shrimp. Pat completely dry with paper towels. Toss with 1/2 tsp salt, cracked pepper, and a pinch of chili flakes.', duration: '5 min'),
            RecipeStep(title: 'Saute aromatics', description: 'Heat chili oil in a wok over high heat until shimmering. Add minced garlic and fry for 30 seconds, stirring constantly, until fragrant and just golden.', duration: '3 min'),
            RecipeStep(title: 'Fry rice & shrimp', description: 'Add shrimp to wok — cook 2 min each side until pink. Push aside, add cooled rice. Toss everything on high heat for 4-5 minutes until lightly charred.', duration: '8 min'),
            RecipeStep(title: 'Finish & plate', description: 'Season with soy sauce and a drop of sesame oil. Taste and adjust. Plate, top with sliced spring onion and a squeeze of lime. Serve immediately.', duration: '2 min'),
          ],
        ),
        const FoodItemData(
          title: "Japanese Katsu Curry",
          description: "A perfect balance of crispy katsu and aromatic curry sauce, crafted for true comfort.",
          rating: 4.7,
          imageUrl: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=1000&auto=format&fit=crop&q=80",
          category: "Dinner",
          prepTime: "30 Min",
          calories: "580 kcal",
          servings: "2",
          proteins: "34 g",
          fats: "22 g",
          carbs: "68 g",
          ingredients: ['Chicken Breast', 'Panko Crumbs', 'Curry Sauce', 'Steamed Rice', 'Daikon'],
          steps: [
            RecipeStep(title: 'Prep the chicken', description: 'Pound chicken breast to an even 1.5 cm thickness. Season generously on both sides with salt, cracked pepper, and a pinch of garlic powder.', duration: '5 min'),
            RecipeStep(title: 'Coat & bread', description: 'Set up three stations: flour, beaten egg, panko crumbs. Dust chicken in flour, dip in egg, then press firmly into panko until fully and evenly coated.', duration: '5 min'),
            RecipeStep(title: 'Deep fry', description: 'Heat oil to 180C. Gently lower chicken and fry 5-7 minutes until deep golden brown on both sides. Drain on a wire rack, not paper towels.', duration: '10 min'),
            RecipeStep(title: 'Warm curry sauce', description: 'In a small saucepan, warm curry sauce over medium heat for 5 minutes. Add a splash of chicken stock and stir until silky and just simmering.', duration: '5 min'),
            RecipeStep(title: 'Plate & serve', description: 'Slice katsu on a clean diagonal. Fan over steamed rice. Spoon curry sauce generously alongside. Garnish with julienned pickled daikon and sesame seeds.', duration: '3 min'),
          ],
        ),
        const FoodItemData(
          title: "Classic Egg Toast",
          description: "Buttery toast layered with perfectly cooked eggs — a timeless breakfast favorite.",
          rating: 4.5,
          imageUrl: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=1000&auto=format&fit=crop&q=80",
          category: "Breakfast",
          prepTime: "10 Min",
          calories: "320 kcal",
          servings: "1",
          proteins: "14 g",
          fats: "18 g",
          carbs: "28 g",
          ingredients: ['Sourdough Bread', 'Eggs', 'Butter', 'Sea Salt', 'Fresh Chives'],
          steps: [
            RecipeStep(title: 'Toast the bread', description: 'Spread butter on one side of sourdough slices. Place butter-side down in a cold pan, then bring to medium heat. Toast 3-4 min until deep golden and crisp.', duration: '4 min'),
            RecipeStep(title: 'Prep the pan', description: 'Add a fresh knob of butter to a non-stick pan over the lowest possible heat. Let it melt gently, swirling the pan — it should foam but not brown at all.', duration: '1 min'),
            RecipeStep(title: 'Cook the eggs', description: 'Crack eggs gently into the pan one at a time. Cook undisturbed on very low heat for 3-4 minutes. Whites should be just set; yolks should stay runny.', duration: '4 min'),
            RecipeStep(title: 'Season & plate', description: 'Slide eggs carefully onto toast. Immediately season with flaky sea salt and freshly cracked pepper. Finish with a scatter of finely chopped fresh chives.', duration: '1 min'),
          ],
        ),
        const FoodItemData(
          title: "Pancakes with Syrup",
          description: "Fluffy pancakes served with maple syrup and fresh berries.",
          rating: 4.8,
          imageUrl: "https://images.unsplash.com/photo-1528207776546-384cb1119671?w=1000&auto=format&fit=crop&q=80",
          category: "Breakfast",
          prepTime: "15 Min",
          calories: "420 kcal",
          servings: "2",
          proteins: "10 g",
          fats: "16 g",
          carbs: "58 g",
          ingredients: ['Flour', 'Eggs', 'Buttermilk', 'Maple Syrup', 'Fresh Berries'],
          steps: [
            RecipeStep(title: 'Mix the batter', description: 'Combine 200g flour, 2 tsp baking powder, 1 tbsp sugar, and 1/2 tsp salt. In a separate bowl whisk 2 eggs and 240ml buttermilk. Combine — small lumps are fine, do not over-mix.', duration: '4 min'),
            RecipeStep(title: 'Rest the batter', description: 'Cover batter and rest for 5 minutes. This activates the baking powder and allows gluten to relax, giving you dramatically fluffier pancakes.', duration: '5 min'),
            RecipeStep(title: 'Cook pancakes', description: 'Butter a pan over medium heat. Pour 1/4 cup batter per pancake. Cook until bubbles form and edges look set (about 2 min). Flip once, cook 1 more minute.', duration: '10 min'),
            RecipeStep(title: 'Stack & serve', description: 'Stack 3-4 pancakes, drizzle generously with warm maple syrup. Pile fresh berries on top. Optional: a light dusting of icing sugar for presentation.', duration: '2 min'),
          ],
        ),
        const FoodItemData(
          title: "Creamy Tomato Soup",
          description: "Rich and creamy tomato soup, perfect for a cozy evening.",
          rating: 4.6,
          imageUrl: "https://images.unsplash.com/photo-1547592180-85f173990554?w=1000&auto=format&fit=crop&q=80",
          category: "Soup",
          prepTime: "25 Min",
          calories: "280 kcal",
          servings: "2",
          proteins: "6 g",
          fats: "16 g",
          carbs: "30 g",
          ingredients: ['Tomatoes', 'Heavy Cream', 'Onion', 'Garlic', 'Fresh Basil'],
          steps: [
            RecipeStep(title: 'Saute the base', description: 'Dice one large onion and mince 4 garlic cloves. Cook in 2 tbsp olive oil over medium heat for 8-10 minutes, stirring occasionally, until very soft and translucent.', duration: '10 min'),
            RecipeStep(title: 'Add tomatoes', description: 'Add one 800g tin of crushed tomatoes and 400ml vegetable stock. Bring to a boil, then reduce heat and simmer uncovered for 15 minutes.', duration: '15 min'),
            RecipeStep(title: 'Blend smooth', description: 'Remove from heat and use an immersion blender to blend completely smooth. Season with salt, black pepper, and a tiny pinch of sugar to balance acidity.', duration: '3 min'),
            RecipeStep(title: 'Cream & finish', description: 'Return to low heat. Stir in 80ml heavy cream. Simmer 2 more minutes, do not boil. Serve in warm bowls with fresh torn basil and a swirl of cream on top.', duration: '3 min'),
          ],
        ),
        const FoodItemData(
          title: "Iced Caramel Macchiato",
          description: "Chilled espresso layered over milk with a sweet caramel drizzle.",
          rating: 4.7,
          imageUrl: "https://images.unsplash.com/photo-1517705008128-361805f42e86?w=1000&auto=format&fit=crop&q=80",
          category: "Drinks",
          prepTime: "5 Min",
          calories: "250 kcal",
          servings: "1",
          proteins: "8 g",
          fats: "6 g",
          carbs: "38 g",
          ingredients: ['Espresso', 'Whole Milk', 'Vanilla Syrup', 'Caramel Sauce', 'Ice Cubes'],
          steps: [
            RecipeStep(title: 'Build the base', description: 'Fill a tall 400ml glass generously with ice cubes. Pour in 200ml cold whole milk and one pump (15ml) of vanilla syrup. Stir gently to combine.', duration: '1 min'),
            RecipeStep(title: 'Pull espresso', description: 'Brew 2 shots (60ml) of fresh espresso on your machine. For the layered effect, let it cool 30 seconds — too hot and it will cook the milk on impact.', duration: '2 min'),
            RecipeStep(title: 'Layer & drizzle', description: 'Slowly pour espresso over the back of a spoon held just above the milk — the two layers should stay visually separate. Drizzle caramel generously in a spiral pattern.', duration: '1 min'),
            RecipeStep(title: 'Serve immediately', description: 'Give the caramel one gentle stir just before drinking to bring the flavours together. Best enjoyed within 3 minutes before the ice dilutes it.', duration: '1 min'),
          ],
        ),
        const FoodItemData(
          title: "Chicken Noodle Soup",
          description: "Comforting chicken noodle soup with fresh vegetables.",
          rating: 4.9,
          imageUrl: "https://images.unsplash.com/photo-1603105037880-8ea2bc26dcc6?w=1000&auto=format&fit=crop&q=80",
          category: "Soup",
          prepTime: "40 Min",
          calories: "320 kcal",
          servings: "4",
          proteins: "28 g",
          fats: "8 g",
          carbs: "34 g",
          ingredients: ['Chicken', 'Egg Noodles', 'Carrots', 'Celery', 'Chicken Stock'],
          steps: [
            RecipeStep(title: 'Poach the chicken', description: 'Place chicken breasts in a large pot with chicken stock. Bring to a gentle simmer and poach for 20 minutes until cooked through. Remove and shred.', duration: '22 min'),
            RecipeStep(title: 'Saute vegetables', description: 'In the same pot, saute diced onion, sliced carrots, and sliced celery in a little oil for 5 minutes until softened.', duration: '5 min'),
            RecipeStep(title: 'Simmer soup', description: 'Return the stock to the pot with the vegetables. Add the shredded chicken. Season with salt, pepper, and a bay leaf. Simmer for 10 minutes.', duration: '10 min'),
            RecipeStep(title: 'Cook noodles', description: 'Add egg noodles directly to the soup. Cook according to package directions until al dente, about 6-8 minutes.', duration: '8 min'),
          ],
        ),
        const FoodItemData(
          title: "Tropical Mango Smoothie",
          description: "Refreshing blend of ripe mangoes, yogurt, and honey.",
          rating: 4.8,
          imageUrl: "https://images.unsplash.com/photo-1628557044797-f21a177c37ec?w=1000&auto=format&fit=crop&q=80",
          category: "Drinks",
          prepTime: "5 Min",
          calories: "210 kcal",
          servings: "1",
          proteins: "5 g",
          fats: "2 g",
          carbs: "44 g",
          ingredients: ['Mango', 'Greek Yogurt', 'Honey', 'Lime Juice', 'Ice'],
          steps: [
            RecipeStep(title: 'Prep the mango', description: 'Peel and roughly chop one large ripe mango. If using frozen mango, measure about 200g.', duration: '2 min'),
            RecipeStep(title: 'Blend', description: 'Add mango, 120ml Greek yogurt, 1 tbsp honey, a squeeze of lime juice, and a handful of ice to a blender. Blend on high for 60 seconds until completely smooth.', duration: '2 min'),
            RecipeStep(title: 'Taste & serve', description: 'Taste and add more honey or lime as needed. Pour into a chilled glass and serve immediately with a wedge of lime.', duration: '1 min'),
          ],
        ),
      ];

      emit(HomeLoaded(categories: categories, foodItems: foodItems));
    } catch (e) {
      emit(const HomeError("Failed to load data"));
    }
  }
}
