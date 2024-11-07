# 🛒 eCommerce App with Firebase Integration

This **eCommerce app** allows users to browse products, manage their favorites, place orders, make payments, and write reviews. Built with **Firebase** for backend services such as authentication, product storage, and order management, the app offers a seamless shopping experience with real-time updates.

<img src="assets/splashscreen.gif" width="200">

---

## 📱 Features

- **User Authentication**: Secure login and registration using Firebase Authentication.  
  <img src="assets/login.jpg" width="200">  
  <img src="assets/register.jpg" width="200">

- **Product Management**: Browse, search, and filter products. Users can add products to their favorites and cart.  
  <img src="assets/homescreen.jpg" width="200">  
  <img src="assets/favorite.jpg" width="200">

- **Cart and Orders**: Users can add products to their cart, view order summaries, and place orders with integrated payment processing.  
  <img src="assets/cartscreen2500p.jpg" width="200">  
  <img src="assets/confirmorder.jpg" width="200">

- **Payments**: Secure payments via Firebase, with real-time order status updates.  
  <img src="assets/payment.jpg" width="200">

- **Reviews and Ratings**: Users can write reviews and rate products. They can also view reviews from other users.  
  <img src="assets/writereview.jpg" width="200">  
  <img src="assets/reviewlist.jpg" width="200">

- **Dark Mode**: Full dark mode support for a better user experience.  
  <img src="assets/darkhome.jpg" width="200">  
  <img src="assets/darkfavorite.jpg" width="200">

---

## 📸 Screenshots

| Splash Screen       | Welcome Screen      | Login Screen        |
|---------------------|---------------------|---------------------|
| <img src="assets/splashscreen.jpg" width="150"> | <img src="assets/welcome.jpg" width="150"> | <img src="assets/login.jpg" width="150"> |

| Home Screen         | Cart Screen         | Confirm Order       |
|---------------------|---------------------|---------------------|
| <img src="assets/homescreen.jpg" width="150"> | <img src="assets/cartscreen2500m.jpg" width="150"> | <img src="assets/confirmorder.jpg" width="150"> |

| Payment Screen      | Order List          | Profile Screen      |
|---------------------|---------------------|---------------------|
| <img src="assets/payment.jpg" width="150"> | <img src="assets/orderlist.jpg" width="150"> | <img src="assets/profile.jpg" width="150"> |

| Dark Mode Home      | Dark Mode Order List| Dark Mode Review    |
|---------------------|---------------------|---------------------|
| <img src="assets/darkhome.jpg" width="150"> | <img src="assets/darkorderlist.jpg" width="150"> | <img src="assets/darkreview.jpg" width="150"> |

---

## 🛠️ Built With

- **Flutter**: Cross-platform mobile framework for building high-performance apps.
- **Firebase**: Backend services for authentication, product storage, orders, payments, and reviews.
- **Lottie**: Smooth animations for splash screens and payment processing.
  
  Example Lottie animations used:
  - **Splash Screen Animation**: `assets/splash.json`
  - **Payment Processing Animation**: `assets/paymentprocessing.json`
  - **Payment Success Animation**: `assets/paymentdone.json`
  - **Forgot Password Animation**: `assets/forgotpass.json`

---

## 📂 Project Structure

```plaintext
ecommerceapp/
│
├── lib/
│   ├── main.dart                  # Entry point of the app
│   ├── screens/                   # Screens like Login, Home, Cart, Order, etc.
│   ├── services/                  # Firebase services for authentication, product, order, and payment management
│   ├── models/                    # Data models for Product, User, Order, Review, etc.
│   └── widgets/                   # Reusable UI components like buttons, forms, etc.
├── assets/                        # App assets (images, Lottie animations)
├── pubspec.yaml                   # Project dependencies
└── README.md                      # Project documentation
```

---

## 🚀 How to Run Locally

1. **Clone the repository**:
   ```bash
   git clone https://github.com/obaidullah72/ecommerceapp.git
   cd ecommerceapp
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:
   - Follow the [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup) to configure Firebase for your app.
   - Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) from the Firebase Console and add it to the respective platforms.

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🚀 Future Enhancements

- **Push Notifications**: Real-time notifications for order status and updates.
- **Wishlist Feature**: Add products to a wishlist for future purchases.
- **Discounts and Coupons**: Support for promo codes and discount offers.
- **Localization**: Support for multiple languages.

---

## 🤝 Contributing

We welcome contributions! Feel free to submit a **pull request** or open an issue to discuss potential improvements.

---

## 🛡️ License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

For any questions or suggestions, feel free to reach out:

- **GitHub**: [obaidullah72](https://github.com/obaidullah72)
- **LinkedIn**: [obaidullah72](https://www.linkedin.com/in/obaidullah72/)

---

[![Visitor Count](https://visitcount.itsvg.in/api?id=obaidullah72&label=Profile%20Views&color=0&icon=0&pretty=true)](https://visitcount.itsvg.in)
