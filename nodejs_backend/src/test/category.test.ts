import axios from 'axios';

const BASE_URL = 'http://localhost:3000';

// Create axios instances for each API
const userApi = axios.create({
    baseURL: `${BASE_URL}/users`,
    headers: { 'Content-Type': 'application/json' },
});

const categoryApi = axios.create({
    baseURL: `${BASE_URL}/categories`,
    headers: { 'Content-Type': 'application/json' },
});

const todoApi = axios.create({
    baseURL: `${BASE_URL}/todos`,
    headers: { 'Content-Type': 'application/json' },
});

// Global variables to store test data
let testUserId = '';
let testToken = '';
let testCategoryId = '';
let testTodoId = '';

// ==================== USER API TESTS ====================
async function testCreateUser() {
    console.log('\n=== Test: Create User ===');
    try {
        const response = await userApi.post('/createUser', {
            email: `testuser${Date.now()}@example.com`,
            password: 'password123',
        });
        console.log('✓ Create User Success:', response.data);
        testUserId = response.data.success._id;
        return testUserId;
    } catch (error: any) {
        console.error('✗ Create User Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testLoginUser() {
    console.log('\n=== Test: Login User ===');
    try {
        const response = await userApi.post('/login', {
            email: `testuser1778485347245@example.com`,
            password: 'password123',
        });
        console.log('✓ Login Success:', response.data);
        testToken = response.data.success?.token;
        return testToken;
    } catch (error: any) {
        console.error('✗ Login Failed (Expected if user not created):', error.response?.data?.message || error.message);
        return null;
    }
}

async function testSendOTP() {
    console.log('\n=== Test: Send OTP ===');
    try {
        const response = await userApi.post('/send-otp', {
            email: `testuser1778485347245@example.com`,
        });
        console.log('✓ Send OTP Success:', response.data);
        return true;
    } catch (error: any) {
        console.error('✗ Send OTP Failed:', error.response?.data?.message || error.message);
        return false;
    }
}

async function testAddOrder() {
    console.log('\n=== Test: Add Order ===');
    if (!testUserId) {
        console.error('✗ Add Order Skipped: No user ID');
        return null;
    }
    try {
        const response = await userApi.post('/addOrder', {
            userId: testUserId,
            food: [
                { food_id: 'sushi_combo_001', quantity: 3 },
                { food_id: 'ramen_bowl_002', quantity: 2 },
                { food_id: 'tempura_003', quantity: 1 },
            ],
            total: 59.95,
        });
        console.log('✓ Add Order Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Add Order Failed:', error.response?.data || error.message);
        return null;
    }
}

// ==================== CATEGORY API TESTS ====================
async function testAddCategory() {
    console.log('\n=== Test: Add Category ===');
    try {
        const response = await categoryApi.post('/addCategory', {
            name: `Japanese Cuisine ${Date.now()}`,
            image_url: 'https://example.com/japanese-food.jpg',
            food: [
                {
                    name: 'Sushi Combo',
                    image_url: 'https://example.com/sushi.jpg',
                    price: 12.99,
                },
                {
                    name: 'Ramen Bowl',
                    image_url: 'https://example.com/ramen.jpg',
                    price: 9.99,
                },
                {
                    name: 'Tempura',
                    image_url: 'https://example.com/tempura.jpg',
                    price: 8.99,
                },
            ],
        });
        console.log('✓ Add Category Success:', response.data);
        testCategoryId = response.data.success._id;
        return testCategoryId;
    } catch (error: any) {
        console.error('✗ Add Category Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testGetCategory() {
    console.log('\n=== Test: Get All Categories ===');
    try {
        const response = await categoryApi.get('/getCategory');
        console.log('✓ Get Categories Success: Found', response.data.success.length, 'categories');
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Get Categories Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testAddFood() {
    console.log('\n=== Test: Add Food to Category ===');
    if (!testCategoryId) {
        console.error('✗ Add Food Skipped: No category ID');
        return null;
    }
    try {
        const response = await categoryApi.post('/addFood', {
            categoryId: testCategoryId,
            name: 'Tonkatsu Pork Cutlet',
            image_url: 'https://example.com/tonkatsu.jpg',
            price: 11.99,
        });
        console.log('✓ Add Food Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Add Food Failed:', error.response?.data || error.message);
        return null;
    }
}

async function testGetFood() {
    console.log('\n=== Test: Get Food by Category ID ===');
    if (!testCategoryId) {
        console.error('✗ Get Food Skipped: No category ID');
        return null;
    }
    try {
        const response = await categoryApi.get(`/getFood/${testCategoryId}`);
        console.log('✓ Get Food Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Get Food Failed:', error.response?.data || error.message);
        return null;
    }
}

// ==================== TODO API TESTS ====================
async function testCreateTodo() {
    console.log('\n=== Test: Create Todo ===');
    if (!testToken) {
        console.error('✗ Create Todo Skipped: No auth token');
        return null;
    }
    try {
        const response = await todoApi.post('/createToDo',
            {
                title: `Order Delivery - ${Date.now()}`,
                description: 'Prepare and deliver Japanese cuisine order to customer',
            },
            {
                headers: { Authorization: `Bearer ${testToken}` },
            }
        );
        console.log('✓ Create Todo Success:', response.data);
        testTodoId = response.data.success?._id;
        return testTodoId;
    } catch (error: any) {
        console.error('✗ Create Todo Failed:', error.response?.data?.message || error.message);
        return null;
    }
}

async function testGetUserTodos() {
    console.log('\n=== Test: Get User Todos ===');
    if (!testToken) {
        console.error('✗ Get Todos Skipped: No auth token');
        return null;
    }
    try {
        const response = await todoApi.get('/getUserTodoList', {
            headers: { Authorization: `Bearer ${testToken}` },
        });
        console.log('✓ Get Todos Success: Found', response.data.success?.length || 0, 'todos');
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Get Todos Failed:', error.response?.data?.message || error.message);
        return null;
    }
}

async function testUpdateTodo() {
    console.log('\n=== Test: Update Todo ===');
    if (!testToken || !testTodoId) {
        console.error('✗ Update Todo Skipped: No auth token or todo ID');
        return null;
    }
    try {
        const response = await todoApi.post(
            '/updateTodo',
            {
                todoId: testTodoId,
                title: `Order Delivery - COMPLETED ${Date.now()}`,
                description: 'Japanese cuisine order successfully delivered to customer address',
            },
            {
                headers: { Authorization: `Bearer ${testToken}` },
            }
        );
        console.log('✓ Update Todo Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Update Todo Failed:', error.response?.data?.message || error.message);
        return null;
    }
}

async function testDeleteTodo() {
    console.log('\n=== Test: Delete Todo ===');
    if (!testToken || !testTodoId) {
        console.error('✗ Delete Todo Skipped: No auth token or todo ID');
        return null;
    }
    try {
        const response = await todoApi.post(
            '/deleteTodo',
            {
                todoId: testTodoId,
            },
            {
                headers: { Authorization: `Bearer ${testToken}` },
            }
        );
        console.log('✓ Delete Todo Success:', response.data);
        return response.data.success;
    } catch (error: any) {
        console.error('✗ Delete Todo Failed:', error.response?.data?.message || error.message);
        return null;
    }
}

// ==================== MAIN TEST RUNNER ====================
async function runAllTests() {
    console.log('\n====================================');
    console.log('  COMPREHENSIVE API TEST SUITE');
    console.log('====================================');
    console.log('Base URL:', BASE_URL);
    console.log('Server must be running on port 3000\n');

    // USER TESTS
    console.log('\n--- USER API TESTS ---');
    await testCreateUser();
    await testLoginUser();
    await testSendOTP();
    await testAddOrder();

    // CATEGORY TESTS
    console.log('\n--- CATEGORY API TESTS ---');
    await testAddCategory();
    await testGetCategory();
    await testAddFood();
    await testGetFood();


    console.log('\n====================================');
    console.log('  ALL TESTS COMPLETED');
    console.log('====================================\n');
}

// Run tests
runAllTests().catch(console.error);
