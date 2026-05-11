import axios from 'axios';

const BASE_URL = 'http://localhost:3000';

const categoryApi = axios.create({
    baseURL: `${BASE_URL}/categories`,
    headers: { 'Content-Type': 'application/json' },
});

const cuisineCategories = [
    { name: 'Chinese', image_url: 'assets/chinese_food.jpg' },
    { name: 'South Indian', image_url: 'assets/south_indian.jpg' },
    { name: 'Beverages', image_url: 'assets/beverage.jpg' },
    { name: 'North India', image_url: 'assets/indian-big-thali-food_1059430-62887.jpg' },
    { name: 'Korean', image_url: 'assets/korea_food.jpg' },
    { name: 'Vietnamese', image_url: 'assets/popular-vietnamese-foods.jpg' },
];

async function addCategories() {
    console.log('\n=== Seed Category Data ===');

    for (const category of cuisineCategories) {
        try {
            const response = await categoryApi.post('/addCategory', category);
            console.log(`✓ Added ${category.name}:`, response.data);
        } catch (error: any) {
            console.error(`✗ Failed to add ${category.name}:`, error.response?.data || error.message);
        }
    }

    console.log('\n=== Category Seed Complete ===\n');
}

async function getCategories() {
    console.log('\n=== Test Get Categories ===');

    try {
        const response = await categoryApi.get('/getCategory');
        const categories = response.data.success || [];
        console.log(`✓ Get Categories Success: ${categories.length} categories found`);
        console.log(categories);
        return categories;
    } catch (error: any) {
        console.error('✗ Get Categories Failed:', error.response?.data || error.message);
        return null;
    }
}

async function run() {
    //await addCategories();
    await getCategories();
}

run().catch(console.error);
