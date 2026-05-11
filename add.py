import requests

url = "http://localhost:5000/api/category/addCategory"

categories = [
    {
        "name": "Chinese",
        "image_url": "assets/chinese_food.jpg",
        "food": []
    },
    {
        "name": "South Indian",
        "image_url": "assets/south_indian.jpg",
        "food": []
    },
    {
        "name": "Beverages",
        "image_url": "assets/beverage.jpg",
        "food": []
    },
    {
        "name": "North India",
        "image_url": "assets/indian-big-thali-food_1059430-62887.jpg",
        "food": []
    },
    {
        "name": "Korean",
        "image_url": "assets/korea_food.jpg",
        "food": []
    },
    {
        "name": "Vietnamese",
        "image_url": "assets/popular-vietnamese-foods.jpg",
        "food": []
    }
]

headers = {
    "Content-Type": "application/json"
}

for category in categories:
    response = requests.post(
        url,
        json=category,
        headers=headers
    )

    print(f"Status: {response.status_code}")
    print(response.json())
    print("-" * 50)