# Complete Google Play Console Configuration

## Phase 1: Build Signed Release APK

### Step 1: Generate Keystore (if you don't have upload-keystore.jks)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Build Release APK
```bash
cd "c:\Users\Hamza\OneDrive\Desktop\VPN_MAX_FRONTBACK\Vpn-Max"
flutter clean
flutter pub get
flutter build apk --release
```

The signed APK will be at: `build\app\outputs\flutter-apk\app-release.apk`

---

## Phase 2: Google Play Console Setup

### Step 1: Create Developer Account
1. Go to https://play.google.com/console
2. Sign up with Google account
3. Pay $25 registration fee
4. Complete profile and tax information

### Step 2: Create App
1. Click "Create app"
2. App details:
   - **App name**: VPN Max
   - **Default language**: English (United States)  
   - **App or game**: App
   - **Free or paid**: Free
   - **Content rating**: For Everyone
3. Accept Play Console Developer Policy
4. Accept US export laws

### Step 3: App Information
1. **App details**:
   - Short description: "Secure and fast VPN service with premium features"
   - Full description: Detailed VPN app description
   - App icon: 512x512 PNG
   - Screenshots: At least 2 for phone, tablet

2. **Store listing**:
   - Category: Tools
   - Tags: VPN, Security, Privacy
   - Contact details: Your email
   - Privacy Policy: Required URL

---

## Phase 3: In-App Products Configuration

### Step 1: Go to Products > In-app products

### Step 2: Create Monthly Subscription
1. Click "Create product"
2. **Product details**:
   - Product ID: `vpnmax_999_1m`
   - Product type: Subscription
   - Product name: VPN Max Monthly
   - Product description: Monthly VPN subscription with unlimited access to all premium features

3. **Pricing**:
   - Base plan ID: `monthly-plan`
   - Billing period: 1 month
   - Price: $9.99 USD
   - Free trial: 3 days (optional)

4. **Eligibility**: All countries
5. **Status**: Active

### Step 3: Create Yearly Subscription  
1. Click "Create product"
2. **Product details**:
   - Product ID: `vpnmax_99_1year`
   - Product type: Subscription
   - Product name: VPN Max Yearly
   - Product description: Yearly VPN subscription with unlimited access and 50% savings

3. **Pricing**:
   - Base plan ID: `yearly-plan` 
   - Billing period: 1 year
   - Price: $99.99 USD
   - Free trial: 7 days (optional)

4. **Eligibility**: All countries
5. **Status**: Active

### Step 4: Create Lifetime Purchase
1. Click "Create product"
2. **Product details**:
   - Product ID: `one_time_purchase`
   - Product type: One-time product
   - Product name: VPN Max Lifetime
   - Product description: One-time purchase for lifetime VPN access

3. **Pricing**:
   - Price: $299.99 USD

4. **Eligibility**: All countries  
5. **Status**: Active

---

## Phase 4: Testing Setup

### Step 1: License Testing
1. Go to **Setup > License testing**
2. Add test account emails
3. Set license testing response: RESPOND_NORMALLY

### Step 2: Internal Testing Track
1. Go to **Release > Testing > Internal testing**
2. Click "Create new release"
3. Upload your signed release APK
4. Add release notes
5. Save and review release
6. Add internal testers (email addresses)

### Step 3: Test In-App Purchases
1. Install the internal testing APK on test device
2. Sign in with test account
3. Test purchasing each subscription plan
4. Verify purchase flow opens Google Play payment
5. Confirm subscription management works

---

## Phase 5: API Configuration (Optional)

### For Server-Side Purchase Verification:
1. Go to **Setup > API access**
2. Link Google Cloud project
3. Create service account
4. Download JSON key file
5. Use Google Play Developer API for purchase verification

---

## Important Notes

⚠️ **Critical Requirements**:
- Must use signed release APK (not debug)
- In-app products take 2-24 hours to activate
- Test on real devices, not emulators
- Complete store listing before testing
- Privacy policy URL required for apps with subscriptions

✅ **Testing Checklist**:
- [ ] Upload signed APK to internal testing
- [ ] Create all 3 in-app products
- [ ] Add test accounts
- [ ] Install and test on real device
- [ ] Verify Google Play payment opens
- [ ] Test subscription management
- [ ] Test purchase restoration

🚀 **Going Live**:
- Submit app for review after testing
- Can take 7-48 hours for approval
- Monitor crash reports and user feedback

---

## Troubleshooting

**"Item not found" error**: Products not yet active (wait 24 hours)
**"App not published"**: Use internal testing track first  
**"Authentication required"**: Sign in with test account
**"Purchase failed"**: Check product IDs match exactly
