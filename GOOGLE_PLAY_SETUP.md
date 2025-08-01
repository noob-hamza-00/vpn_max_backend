# Google Play Console Setup Guide

## Prerequisites
1. Google account
2. $25 one-time registration fee for Google Play Console
3. Signed release APK of your app

## Step 1: Google Play Console Account
1. Go to https://play.google.com/console
2. Sign in with your Google account
3. Pay the $25 registration fee
4. Accept the Developer Distribution Agreement

## Step 2: Create Your App
1. Click "Create app" in Google Play Console
2. Fill in app details:
   - App name: "VPN Max"
   - Default language: English (United States)
   - App or game: App
   - Free or paid: Free (with in-app purchases)
   - Declarations: Check all required boxes

## Step 3: Upload Your App
1. Go to "Release" > "Production" (or "Internal testing" for testing)
2. Click "Create new release"
3. Upload your signed APK
4. Fill in release notes
5. Save (don't publish yet)

## Step 4: Set Up In-App Products
1. Go to "Monetize" > "Products" > "In-app products"
2. Click "Create product" for each subscription

### Product 1: Monthly Subscription
- Product ID: `vpnmax_999_1m`
- Name: VPN Max Monthly
- Description: Monthly VPN subscription with unlimited access
- Price: $9.99
- Status: Active

### Product 2: Yearly Subscription  
- Product ID: `vpnmax_99_1year`
- Name: VPN Max Yearly
- Description: Yearly VPN subscription with unlimited access
- Price: $99.99
- Status: Active

### Product 3: Lifetime Purchase
- Product ID: `one_time_purchase`
- Name: VPN Max Lifetime
- Description: One-time VPN purchase with lifetime access
- Price: $299.99
- Status: Active

## Step 5: Configure Licensing & API Access
1. Go to "Setup" > "API access"
2. Link a Google Cloud project or create new one
3. Create service account for API access
4. Download the service account JSON key

## Step 6: Test Your In-App Purchases
1. Add test accounts in "Setup" > "License testing"
2. Use internal testing track to test purchases
3. Install the signed APK on test devices

## Important Notes
- It can take up to 24 hours for in-app products to become active
- You need a signed release APK (not debug) for real IAP testing
- Test accounts can make purchases without being charged
- Always test on real devices, not emulators

## Next Steps After Setup
1. Build signed release APK
2. Upload to internal testing
3. Test in-app purchases with test accounts
4. Once working, submit for review and publish
