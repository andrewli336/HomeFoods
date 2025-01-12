//
//  sampleKitchens.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import CoreLocation

let sampleKitchens = [
    // Chinese Cuisine
    Kitchen(
        name: "Happy & Healthy Kitchen",
        description: "Fresh and homemade Chinese food made with love by experienced chef Huifang.",
        cuisine: "Chinese",
        rating: 4.9,
        location: CLLocationCoordinate2D(latitude: 37.549099, longitude: -121.943069),
        foodItems: [
            FoodItem(
                name: "Braised Beef Tendon",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Tender beef tendon braised in a savory soy-based sauce with aromatic spices.",
                foodType: "Main Course",
                rating: 95,
                numRatings: 16,
                cost: 12,
                image: Image("h1"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Rice Dumpling with Pork",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Sticky rice dumplings stuffed with seasoned pork and wrapped in bamboo leaves.",
                foodType: "Main Course",
                rating: 91,
                numRatings: 12,
                cost: 10,
                image: Image("h2"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Sweet and Sour Ribs",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Juicy pork ribs coated in a sweet and tangy sauce with hints of vinegar.",
                foodType: "Main Course",
                rating: 89,
                numRatings: 9,
                cost: 8,
                image: Image("h3"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Pearl Meatballs",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Delicious pork meatballs rolled in glutinous rice, steamed to perfection.",
                foodType: "Main Course",
                rating: 87,
                numRatings: 10,
                cost: 5,
                image: Image("h4"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Banh Mi",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Vietnamese sandwich filled with pork, lettuce, and pickles.",
                foodType: "Main Course",
                rating: 90,
                numRatings: 14,
                cost: 10,
                image: Image("h5"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Braised Brisket",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Succulent beef brisket slow-cooked in a rich, flavorful broth.",
                foodType: "Main Course",
                rating: 88,
                numRatings: 11,
                cost: 8,
                image: Image("h6"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Braised Pork Belly",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Soft and flavorful pork belly braised in soy sauce and Chinese spices.",
                foodType: "Main Course",
                rating: 89,
                numRatings: 13,
                cost: 7,
                image: Image("h7"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Crispy Belt Fish",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Lightly battered belt fish fried until golden and crispy, served with a dipping sauce.",
                foodType: "Main Course",
                rating: 85,
                numRatings: 8,
                cost: 6,
                image: Image("h8"),
                isFeatured: false,
                numAvailable: 0
            ),
            FoodItem(
                name: "Roasted Pork Feet",
                kitchenName: "Happy & Healthy Kitchen",
                description: "Juicy pork feet roasted to crispy perfection with aromatic seasonings.",
                foodType: "Main Course",
                rating: 92,
                numRatings: 18,
                cost: 5,
                image: Image("h9"),
                isFeatured: true,
                numAvailable: 3
            )
        ],
        image: Image("h1"), preorderSchedule: nil
    ),
    
    Kitchen(
        name: "Golden Wok Delights",
        description: "Experience the authentic taste of Sichuan cuisine with bold flavors and fresh ingredients. Specializing in classic Chinese comfort food.",
        cuisine: "Chinese",
        rating: 4.8,
        location: CLLocationCoordinate2D(latitude: 37.560099, longitude: -121.950069),
        foodItems: [
            FoodItem(
                name: "Kung Pao Chicken",
                kitchenName: "Golden Wok Delights",
                description: "Spicy stir-fried chicken with peanuts, peppers, and a tangy sauce.",
                foodType: "Main Course",
                rating: 80,
                numRatings: 5,
                cost: 12,
                image: Image("food3"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Dan Dan Noodles",
                kitchenName: "Golden Wok Delights",
                description: "Savory noodles topped with minced pork, sesame paste, and a spicy chili oil.",
                foodType: "Main Course",
                rating: 85,
                numRatings: 5,
                cost: 10,
                image: Image("food4"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Mapo Tofu",
                kitchenName: "Golden Wok Delights",
                description: "Silky tofu cooked in a spicy Sichuan pepper sauce with minced pork.",
                foodType: "Main Course",
                rating: 84,
                numRatings: 5,
                cost: 9,
                image: Image("food5"),
                isFeatured: false,
                numAvailable: 5
            )
        ],
        image: Image("food3"), preorderSchedule: nil
    ),
    
    Kitchen(
        name: "Dragon's Pearl Bistro",
        description: "A modern take on traditional Chinese dishes, featuring unique flavors and creative presentations. Perfect for foodies!",
        cuisine: "Chinese",
        rating: 4.9,
        location: CLLocationCoordinate2D(latitude: 37.550099, longitude: -121.945069),
        foodItems: [
            FoodItem(
                name: "Peking Duck",
                kitchenName: "Dragon's Pearl Bistro",
                description: "Crispy roasted duck served with pancakes, hoisin sauce, and scallions.",
                foodType: "Main Course",
                rating: 82,
                numRatings: 5,
                cost: 20,
                image: Image("food7"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Sesame Chicken",
                kitchenName: "Dragon's Pearl Bistro",
                description: "Tender chicken coated in a sweet sesame sauce with a crispy crust.",
                foodType: "Main Course",
                rating: 81,
                numRatings: 5,
                cost: 12,
                image: Image("food8"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Hot and Sour Soup",
                kitchenName: "Dragon's Pearl Bistro",
                description: "Classic soup with a tangy, spicy broth and a mix of mushrooms and tofu.",
                foodType: "Appetizer",
                rating: 87,
                numRatings: 5,
                cost: 7,
                image: Image("food9"),
                isFeatured: false,
                numAvailable: 5
            )
        ],
        image: Image("food7"), preorderSchedule: nil
    ),
    
    // Vegan Kitchen 1
    Kitchen(
        name: "Green Garden Eats",
        description: "Delicious plant-based meals crafted with organic ingredients and a passion for sustainability.",
        cuisine: "Vegan",
        rating: 4.7,
        location: CLLocationCoordinate2D(latitude: 37.763099, longitude: -121.942069),
        foodItems: [
            FoodItem(
                name: "Quinoa Avocado Salad",
                kitchenName: "Green Garden Eats",
                description: "A refreshing salad with quinoa, avocado, cherry tomatoes, and a citrus vinaigrette.",
                foodType: "Salad",
                rating: 90,
                numRatings: 5,
                cost: 10,
                image: Image("food4"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Vegan Buddha Bowl",
                kitchenName: "Green Garden Eats",
                description: "A nutritious bowl with roasted vegetables, chickpeas, and tahini dressing.",
                foodType: "Main Course",
                rating: 90,
                numRatings: 5,
                cost: 12,
                image: Image("food5"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Sweet Potato Soup",
                kitchenName: "Green Garden Eats",
                description: "Creamy sweet potato soup with a hint of coconut and spices.",
                foodType: "Soup",
                rating: 50,
                numRatings: 5,
                cost: 8,
                image: Image("food6"),
                isFeatured: false,
                numAvailable: 5
            )
        ],
        image: Image("food4"), preorderSchedule: nil
    ),

    // Vegan Kitchen 2
    Kitchen(
        name: "Pure Plant Bistro",
        description: "Wholesome vegan food with bold flavors and creative presentations, perfect for the health-conscious.",
        cuisine: "Vegan",
        rating: 4.8,
        location: CLLocationCoordinate2D(latitude: 37.764999, longitude: -121.943469),
        foodItems: [
            FoodItem(
                name: "Vegan Mushroom Stroganoff",
                kitchenName: "Pure Plant Bistro",
                description: "Creamy pasta with sautéed mushrooms in a rich vegan stroganoff sauce.",
                foodType: "Main Course",
                rating: 50,
                numRatings: 5,
                cost: 14,
                image: Image("food7"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Jackfruit Tacos",
                kitchenName: "Pure Plant Bistro",
                description: "Soft-shell tacos filled with spiced jackfruit and fresh salsa.",
                foodType: "Main Course",
                rating: 75,
                numRatings: 5,
                cost: 11,
                image: Image("food8"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Chocolate Chia Pudding",
                kitchenName: "Pure Plant Bistro",
                description: "Decadent chia seed pudding with cacao and almond milk.",
                foodType: "Dessert",
                rating: 90,
                numRatings: 5,
                cost: 6,
                image: Image("food9"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food7"), preorderSchedule: nil
    ),

    // Vegan Kitchen 3
    Kitchen(
        name: "Roots & Sprouts",
        description: "A vibrant menu of vegan dishes inspired by global flavors, using only fresh, seasonal ingredients.",
        cuisine: "Vegan",
        rating: 4.9,
        location: CLLocationCoordinate2D(latitude: 37.759099, longitude: -121.950069),
        foodItems: [
            FoodItem(
                name: "Vegan Pad Thai",
                kitchenName: "Roots & Sprouts",
                description: "A Thai classic with rice noodles, tofu, and a zesty peanut sauce.",
                foodType: "Main Course",
                rating: 95,
                numRatings: 5,
                cost: 13,
                image: Image("food1"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Zucchini Noodles with Pesto",
                kitchenName: "Roots & Sprouts",
                description: "Spiralized zucchini tossed in a creamy vegan pesto sauce.",
                foodType: "Main Course",
                rating: 94,
                numRatings: 5,
                cost: 11,
                image: Image("food2"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Carrot Cake Bites",
                kitchenName: "Roots & Sprouts",
                description: "Mini vegan carrot cakes topped with cashew cream frosting.",
                foodType: "Dessert",
                rating: 100,
                numRatings: 5,
                cost: 7,
                image: Image("food3"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food1"), preorderSchedule: nil
    ),
    
    // Dessert Kitchen 1
    Kitchen(
        name: "Sweet Haven",
        description: "A dessert lover’s paradise offering a variety of cakes, cookies, and pastries made fresh daily.",
        cuisine: "Desserts",
        rating: 4.8,
        location: CLLocationCoordinate2D(latitude: 37.759499, longitude: -121.955069),
        foodItems: [
            FoodItem(
                name: "Classic Cheesecake",
                kitchenName: "Sweet Haven",
                description: "Creamy cheesecake with a buttery graham cracker crust.",
                foodType: "Dessert",
                rating: 100,
                numRatings: 5,
                cost: 8,
                image: Image("food4"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Chocolate Eclair",
                kitchenName: "Sweet Haven",
                description: "Delicate choux pastry filled with rich chocolate cream.",
                foodType: "Dessert",
                rating: 98,
                numRatings: 5,
                cost: 6,
                image: Image("food5"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Fruit Tart",
                kitchenName: "Sweet Haven",
                description: "A buttery tart shell filled with custard and topped with fresh fruit.",
                foodType: "Dessert",
                rating: 94,
                numRatings: 5,
                cost: 7,
                image: Image("food6"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food4"), preorderSchedule: nil
    ),

    // Dessert Kitchen 2
    Kitchen(
        name: "Chocolate Bliss",
        description: "A decadent menu focused on all things chocolate, from cakes to truffles to drinks.",
        cuisine: "Desserts",
        rating: 4.9,
        location: CLLocationCoordinate2D(latitude: 37.759999, longitude: -121.952069),
        foodItems: [
            FoodItem(
                name: "Triple Chocolate Cake",
                kitchenName: "Chocolate Bliss",
                description: "A rich chocolate cake layered with dark chocolate ganache.",
                foodType: "Dessert",
                rating: 87,
                numRatings: 5,
                cost: 9,
                image: Image("food7"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Chocolate Fondue",
                kitchenName: "Chocolate Bliss",
                description: "Warm melted chocolate served with fresh fruit and marshmallows.",
                foodType: "Dessert",
                rating: 72,
                numRatings: 5,
                cost: 10,
                image: Image("food8"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Hot Cocoa with Whipped Cream",
                kitchenName: "Chocolate Bliss",
                description: "Creamy hot cocoa topped with fresh whipped cream.",
                foodType: "Drink",
                rating: 76,
                numRatings: 5,
                cost: 5,
                image: Image("food9"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food7"), preorderSchedule: nil
    ),

    // Dessert Kitchen 3
    Kitchen(
        name: "Berrylicious Desserts",
        description: "The perfect spot for fruit-based desserts, featuring fresh seasonal berries in every dish.",
        cuisine: "Desserts",
        rating: 4.8,
        location: CLLocationCoordinate2D(latitude: 37.760099, longitude: -121.951069),
        foodItems: [
            FoodItem(
                name: "Strawberry Shortcake",
                kitchenName: "Berrylicious Desserts",
                description: "Fluffy cake layered with strawberries and whipped cream.",
                foodType: "Dessert",
                rating: 55,
                numRatings: 5,
                cost: 8,
                image: Image("food1"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Mixed Berry Parfait",
                kitchenName: "Berrylicious Desserts",
                description: "Layers of fresh berries, granola, and yogurt.",
                foodType: "Dessert",
                rating: 77,
                numRatings: 5,
                cost: 7,
                image: Image("food2"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Blueberry Pie",
                kitchenName: "Berrylicious Desserts",
                description: "Traditional blueberry pie with a flaky crust and sweet filling.",
                foodType: "Dessert",
                rating: 66,
                numRatings: 5,
                cost: 9,
                image: Image("food3"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food1"), preorderSchedule: nil
    ),

    // Dessert Kitchen 4
    Kitchen(
        name: "Delightful Bites",
        description: "A cozy spot for cookies, brownies, and bars made with care and served with a smile.",
        cuisine: "Desserts",
        rating: 4.7,
        location: CLLocationCoordinate2D(latitude: 37.760999, longitude: -121.950569),
        foodItems: [
            FoodItem(
                name: "Classic Chocolate Chip Cookies",
                kitchenName: "Delightful Bites",
                description: "Soft and chewy cookies loaded with chocolate chips.",
                foodType: "Dessert",
                rating: 86,
                numRatings: 5,
                cost: 5,
                image: Image("food6"),
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                name: "Salted Caramel Brownies",
                kitchenName: "Delightful Bites",
                description: "Rich brownies topped with gooey salted caramel.",
                foodType: "Dessert",
                rating: 47,
                numRatings: 5,
                cost: 6,
                image: Image("food7"),
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                name: "Peanut Butter Bars",
                kitchenName: "Delightful Bites",
                description: "Crunchy and sweet peanut butter bars with a chocolate topping.",
                foodType: "Dessert",
                rating: 73,
                numRatings: 5,
                cost: 6,
                image: Image("food8"),
                isFeatured: true,
                numAvailable: 5
            )
        ],
        image: Image("food6"), preorderSchedule: nil
    )
]
