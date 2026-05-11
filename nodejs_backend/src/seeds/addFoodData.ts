// import axios from 'axios';

// const API_URL = 'http://localhost:3000';

// // Dữ liệu từ food_data.dart
// const foodMenuData = {
//   Chinese: [
//     {
//       name: "Vịt Quay Băc Kinh",
//       description: "",
//       price: 12.99,
//       image: "assets/vit_quay_bac_kinh.jpg",
//     },
//     {
//       name: "Thịt Heo Xào Chua Ngọt",
//       description: "",
//       price: 8.50,
//       image: "assets/trungquoc_2.jpg",
//     },
//     {
//       name: "Tàu Hủ Kho Thịt Bằm",
//       description: "",
//       price: 8.50,
//       image: "assets/trungquoc_3.jpg",
//     },
//     {
//       name: "Cơm Chiên Dương Châu",
//       description: "",
//       price: 8.50,
//       image: "assets/trungquoc_4.jpg",
//     },
//   ],

//   "South Indian": [
//     {
//       name: "Cà Ri Đậu Xanh",
//       description: "",
//       price: 15.50,
//       image: "assets/south_indian_1.jpg",
//     },
//     {
//       name: "Cơm Chiên Cà Chua",
//       description: "",
//       price: 15.50,
//       image: "assets/south_indian_2.jpg",
//     },
//     {
//       name: "Rau Korma",
//       description: "",
//       price: 15.50,
//       image: "assets/south_indian_3.jpg",
//     },
//     {
//       name: "Yến Mạch Idli",
//       description: "",
//       price: 15.50,
//       image: "assets/south_indian_4.jpg",
//     },
//   ],

//   Beverages: [
//     {
//       name: "CockTail Dưa Hấu",
//       description: "Thức uống mát lạnh giải nhiệt cho mùa hè.",
//       price: 4.99,
//       image: "assets/cocktail1.jpg",
//     },
//     {
//       name: "Nước Cam",
//       description: "Nước cam tươi ngon, bổ sung vitamin C.",
//       price: 3.50,
//       image: "assets/nuoc_cam.jpg",
//     },
//     {
//       name: "Soda",
//       description: "Nước ngọt có ga, giải khát tuyệt vời.",
//       price: 2.50,
//       image: "assets/soda.jpg",
//     },
//     {
//       name: "Cocktail Mix",
//       description: "Hỗn hợp cocktail đa dạng, phù hợp mọi khẩu vị.",
//       price: 3.50,
//       image: "assets/rainbow-paradise-cocktail-scaled.jpg",
//     },
//   ],

//   "North India": [
//     {
//       name: "BeSan Ladoo",
//       description: "Bánh ngọt truyền thống Ấn Độ làm từ bột đậu xanh và đường.",
//       price: 18.00,
//       image: "assets/besan-ladoo-3.jpg",
//     },
//     {
//       name: "Dal Tadka",
//       description: "Món đậu lăng nấu với gia vị và tỏi phi thơm lừng.",
//       price: 18.00,
//       image: "assets/dal-tadka-1.jpg",
//     },
//     {
//       name: "Paneer Butter Masala",
//       description: "Món cà ri phô mai mềm mại trong nước sốt bơ đậm đà.",
//       price: 18.00,
//       image: "assets/Paneer_Butter_Masala.jpg",
//     },
//     {
//       name: "Phô Mai Thali Bắc Ấn",
//       description: "Thali truyền thống với nhiều món ăn kèm, đặc biệt là phô mai thơm ngon.",
//       price: 18.00,
//       image: "assets/pho_mai_an_do_rau_bina.jpg",
//     },
//   ],

//   Korean: [
//     {
//       name: "Kim Chi",
//       description: "Kim chi truyền thống Hàn Quốc, được làm từ cải thảo lên",
//       price: 14.50,
//       image: "assets/whole-cabbage-kimchi.jpg",
//     },
//     {
//       name: "Mỳ Cay",
//       description: "Mỳ cay Hàn Quốc với nước dùng đậm đà và vị cay nồng đặc trưng.",
//       price: 14.50,
//       image: "assets/mycay.jpg",
//     },
//     {
//       name: "Tokbokki",
//       description: "Bánh gạo cay Tokbokki, món ăn đường phố nổi tiếng của Hàn Quốc.",
//       price: 14.50,
//       image: "assets/tokbokki.jpg",
//     },
//     {
//       name: "Kim Bắp Cuộn",
//       description: "Kim bắp cuộn Hàn Quốc, món ăn nhẹ ngon miệng với lớp vỏ giòn tan và nhân ngọt ngào bên trong.",
//       price: 14.50,
//       image: "assets/kimbap.jpg",
//     },
//   ],

//   Vietnamese: [
//     {
//       name: "Phở Bò",
//       description: "Phở bò truyền thống, nước dùng thanh ngọt đậm đà.",
//       price: 10.00,
//       image: "assets/pho.jpg",
//     },
//     {
//       name: "Bánh mì heo quay",
//       description: "Bánh mì thịt giòn tan, ăn kèm đồ chua đặc trưng.",
//       price: 5.00,
//       image: "assets/banhmi.jpg",
//     },
//     {
//       name: "Bún Bò",
//       description: "Bún bò là món ăn truyền thống của Việt Nam, gồm bún, thịt bò và nước dùng thơm ngon.",
//       price: 5.00,
//       image: "assets/bunbo.jpg",
//     },
//     {
//       name: "Bánh Xèo",
//       description: "Bánh xèo là món ăn truyền thống của Việt Nam, gồm bột gạo rán giòn và nhân thịt, tôm.",
//       price: 5.00,
//       image: "assets/banhxeo.jpg",
//     },
//   ],
// };

// // Category IDs từ database
// const categoryIds: { [key: string]: string } = {
//   Chinese: "6a018bc98696cac0bc01136e",
//   "South Indian": "6a018bc98696cac0bc01136f",
//   Beverages: "6a018bc98696cac0bc011370",
//   "North India": "6a018bca8696cac0bc011371",
//   Korean: "6a018bca8696cac0bc011372",
//   Vietnamese: "6a018bca8696cac0bc011373",
// };

// async function addFoodsToCategories() {
//   try {
//     for (const [categoryName, foods] of Object.entries(foodMenuData)) {
//       const categoryId = categoryIds[categoryName];

//       console.log(`\n📍 Thêm món ăn vào category: ${categoryName}`);

//       for (const food of foods) {
//         try {
//           const response = await axios.post(`${API_URL}/categories/addFood`, {
//             categoryId,
//             name: food.name,
//             image_url: food.image,
//             price: food.price,
//           });

//           console.log(`✅ ${food.name} - Thêm thành công`);
//         } catch (error: any) {
//           console.error(
//             `❌ ${food.name} - Lỗi:`,
//             error.response?.data?.message || error.message
//           );
//         }
//       }
//     }

//     console.log("\n✨ Hoàn tất thêm tất cả dữ liệu!");
//   } catch (error) {
//     console.error("Lỗi chung:", error);
//   }
// }

// // Chạy script
// addFoodsToCategories();
