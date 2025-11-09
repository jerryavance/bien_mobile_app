# FinTech App Screen Structure

This document outlines the organized folder structure for the FinTech app screens.

## Folder Organization

### 📁 `lib/screens/`
The screens are organized into logical groups for better maintainability and scalability.

#### 🏠 **Core Screens** (`lib/screens/core/`)
Main navigation screens that are part of the primary app flow:
- `home_screen.dart` - Main dashboard with overview and quick actions
- `wallet_screen.dart` - Wallet management and balance overview
- `profile_screen.dart` - User profile and account settings
- `settings_screen.dart` - App settings and preferences

#### ⚡ **Feature Screens** (`lib/screens/features/`)
Specific functionality screens for different app features:
- `transactions_screen.dart` - Transaction history and management
- `investment_screen.dart` - Investment portfolio and management
- `budget_screen.dart` - Budget planning and tracking
- `analytics_screen.dart` - Financial analytics and insights
- `cards_screen.dart` - Credit/debit card management
- `savings_screen.dart` - Savings goals and tracking

#### 🔐 **Authentication Screens** (`lib/screens/auth/`)
User authentication and account management:
- `login_screen.dart` - User login with email/password
- `signup_screen.dart` - New user registration

#### 🚀 **Onboarding Screens** (`lib/screens/onboarding/`)
Welcome and app introduction screens:
- `onboarding_screen.dart` - App introduction and feature showcase

## Navigation Flow

```
Onboarding → Login/Signup → Home (Main App)
                ↓
    ┌─────────────────────────────────┐
    │                                 │
    ▼                                 ▼
  Wallet    Profile    Analytics    Settings
    ↓         ↓         ↓            ↓
  Cards    Budget   Investment  Transactions
    ↓         ↓         ↓            ↓
  Savings   ...       ...         ...
```

## Screen Features

### Core Screens
- **Home Screen**: Dashboard with balance overview, quick actions, and recent transactions
- **Wallet Screen**: Account balances, transfer options, and financial overview
- **Profile Screen**: User information, preferences, and account settings
- **Settings Screen**: App configuration, notifications, and security settings

### Feature Screens
- **Transactions Screen**: Complete transaction history with filtering and search
- **Investment Screen**: Portfolio management, market data, and investment tools
- **Budget Screen**: Budget creation, tracking, and spending analysis
- **Analytics Screen**: Financial insights, charts, and performance metrics
- **Cards Screen**: Credit/debit card management with visual card display
- **Savings Screen**: Goal-based savings tracking and progress monitoring

### Authentication Screens
- **Login Screen**: Secure authentication with social login options
- **Signup Screen**: User registration with validation and terms acceptance

### Onboarding Screens
- **Onboarding Screen**: App introduction with feature highlights and navigation

## Benefits of This Structure

1. **Logical Organization**: Screens are grouped by functionality and purpose
2. **Easy Navigation**: Clear separation between core, feature, and utility screens
3. **Scalability**: Easy to add new screens in appropriate categories
4. **Maintainability**: Related screens are kept together for easier updates
5. **Team Collaboration**: Developers can work on different feature areas independently

## Adding New Screens

When adding new screens, follow these guidelines:

1. **Determine the category**: Is it a core screen, feature screen, or utility screen?
2. **Place in appropriate folder**: Add to the corresponding subfolder
3. **Update main.dart**: Add the import and route
4. **Follow naming convention**: Use descriptive names with `_screen.dart` suffix
5. **Maintain consistency**: Follow the existing UI patterns and design system

## Design System Integration

All screens use the centralized design system:
- `AppTheme` for consistent colors, typography, and spacing
- `flutter_animate` for smooth animations and transitions
- Consistent UI components and layout patterns
- Responsive design principles for different screen sizes
