# Database Schema Visual Representation

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           E-COMMERCE DATABASE SCHEMA                            │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    USERS    │────│  ADDRESSES  │    │ CATEGORIES  │────│  PRODUCTS   │
│             │    │             │    │             │    │             │
│ • user_id   │    │ • address_id│    │ • category_id│   │ • product_id│
│ • username  │    │ • user_id   │    │ • name      │    │ • name      │
│ • email     │    │ • street    │    │ • parent_id │    │ • price     │
│ • password  │    │ • city      │    │ • description│   │ • stock     │
│ • name      │    │ • country   │    └─────────────┘    │ • rating    │
│ • phone     │    └─────────────┘                       └─────────────┘
└─────────────┘                                                 │
       │                                                        │
       │                                                        │
       ▼                                                        ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   ORDERS    │────│ ORDER_ITEMS │    │PRODUCT_IMGS │    │  REVIEWS    │
│             │    │             │    │             │    │             │
│ • order_id  │    │ • item_id   │    │ • image_id  │    │ • review_id │
│ • user_id   │    │ • order_id  │    │ • product_id│    │ • product_id│
│ • number    │    │ • product_id│    │ • image_url │    │ • user_id   │
│ • status    │    │ • quantity  │    │ • is_primary│    │ • rating    │
│ • total     │    │ • price     │    └─────────────┘    │ • comment   │
└─────────────┘    └─────────────┘                       └─────────────┘
       │                                                        ▲
       │                                                        │
       ▼                                                        │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │
│   COUPONS   │────│COUPON_USAGE │    │SHOPPING_CART│───────────┘
│             │    │             │    │             │
│ • coupon_id │    │ • usage_id  │    │ • cart_id   │
│ • code      │    │ • coupon_id │    │ • user_id   │
│ • discount  │    │ • user_id   │    │ • product_id│
│ • valid_to  │    │ • order_id  │    │ • quantity  │
└─────────────┘    └─────────────┘    └─────────────┘

┌─────────────┐
│  WISHLIST   │
│             │
│ • wish_id   │
│ • user_id   │
│ • product_id│
│ • added_at  │
└─────────────┘

RELATIONSHIP LEGEND:
────  One-to-Many relationship
│     Foreign Key connection
```

## Key Database Features:

### 🔐 **Security Features:**
- Password hashing for user authentication
- User session management support
- Address separation for billing/shipping

### 🛒 **E-commerce Features:**
- Complete shopping cart functionality
- Order management with status tracking
- Product catalog with categories and images
- User reviews and ratings system
- Discount coupons and promotional codes
- Wishlist functionality

### 📊 **Performance Optimizations:**
- Strategic indexing on frequently queried fields
- Database views for complex queries
- Stored procedures for common operations
- Triggers for automatic data maintenance

### 🔄 **Automated Processes:**
- Automatic product rating calculations
- Order total price computations
- Cart to order conversion procedures
- Data integrity through foreign key constraints

### 🌐 **Internationalization:**
- UTF-8 encoding for Bulgarian language support
- Flexible address format for multiple countries
- Currency support (BGN as default)

This schema provides a solid foundation for a modern e-commerce application with all essential features for online retail business.