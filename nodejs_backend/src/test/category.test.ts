import axios from 'axios';

const BASE_URL = 'http://localhost:3000/categories';

// Helper function to make requests
const api = axios.create({
    baseURL: BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Test data
const testCategoryData = {
    name: 'Vietnamese Food',
    image_url: 'https://example.com/vietnamese.jpg',
    food: [
        {
            name: 'Pho',
            image_url: 'https://example.com/pho.jpg',
            price: 5.99,
        },
        {
            name: 'Banh Mi',
            image_url: 'https://example.com/banh-mi.jpg',
            price: 4.99,
        },
    ],
};

const testFoodData = {
    categoryId: '', // Will be set after category creation
    name: 'Spring Rolls',
    image_url: 'https://example.com/spring-rolls.jpg',
    price: 3.99,
};

// Test functions
async function testAddCategory() {
    console.log('\n=== Test: Add Category ===');
    try {
        const response = await api.post('/addCategory', testCategoryData);
        console.log('✓ Add Category Success:', response.data);
        return response.data.success._id;
    } catch (error: any) {
        console.error('✗ Add Category Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testGetCategory() {
    console.log('\n=== Test: Get All Categories ===');
    try {
        const response = await api.get('/getCategory');
        console.log('✓ Get Categories Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Get Categories Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testAddFood(categoryId: string) {
    console.log('\n=== Test: Add Food to Category ===');
    try {
        testFoodData.categoryId = categoryId;
        const response = await api.post('/addFood', testFoodData);
        console.log('✓ Add Food Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Add Food Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testGetFood(categoryId: string) {
    console.log('\n=== Test: Get Food by Category ID ===');
    try {
        const response = await api.get(`/getFood/${categoryId}`);
        console.log('✓ Get Food Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Get Food Failed:', error.response?.data || error.message);
        return null;
    }
}

// Run all tests
async function runAllTests() {
    console.log('Starting Category API Tests...');
    console.log('Base URL:', BASE_URL);

    // Test 1: Add Category
    const categoryId = await testAddCategory();

    if (!categoryId) {
        console.error('Cannot proceed - Category creation failed');
        return;
    }

    // Test 2: Get All Categories
    await testGetCategory();

    // Test 3: Add Food to Category
    const updatedCategory = await testAddFood(categoryId);

    // Test 4: Get Food by Category ID
    await testGetFood(categoryId);

    console.log('\n=== All Tests Completed ===\n');
}

// Run tests
runAllTests().catch(console.error);
