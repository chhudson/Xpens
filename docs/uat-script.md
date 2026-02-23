# Xpens v1.0 — UAT Test Script

**Device:** iPhone (TestFlight build)
**Tester:** _______________
**Date:** _______________
**Build:** _______________

---

## Pre-Test Setup

- [ ] Delete Xpens from device if previously installed (clean start)
- [ ] Install latest TestFlight build
- [ ] Have a paper receipt or photo of a receipt ready for OCR testing

---

## 1. Onboarding Flow

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 1.1 | Launch app for first time | Welcome screen appears with "Welcome to Xpens" title | | |
| 1.2 | Tap "Next" | Currency selection page appears with USD pre-selected | | |
| 1.3 | Scroll and select "EUR" | EUR row shows checkmark, USD checkmark disappears | | |
| 1.4 | Select "USD" again | USD re-selected with checkmark | | |
| 1.5 | Tap "Next" | Featured categories page appears, "Pick 4 Quick Categories" header, 4/4 pre-selected | | |
| 1.6 | Tap a selected category to deselect | Count changes to 3/4, circle outline replaces filled checkmark | | |
| 1.7 | Re-select it | Count returns to 4/4 | | |
| 1.8 | Tap "Get Started" | Main tab view appears with 4 tabs: Expenses, Add Expense, Reports, Settings | | |
| 1.9 | Verify Expenses tab shows empty state | "No Expenses" message with "Tap + to add your first expense" | | |

---

## 2. Manual Expense Entry

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 2.1 | Tap "+" button in Expenses toolbar | New Expense form appears as sheet | | |
| 2.2 | Tap a featured category (e.g., Food) | Category card highlights with colored border | | |
| 2.3 | Tap "Other" button below categories | All Categories sheet appears with searchable list of 8 categories | | |
| 2.4 | Search for "Park" in category sheet | List filters to show "Parking" | | |
| 2.5 | Select "Parking" and dismiss sheet | Parking is now selected (visible on return) | | |
| 2.6 | Enter amount: 42.50 | Amount field shows 42.50 with $ prefix | | |
| 2.7 | Enter merchant: "Airport Parking" | Text appears in merchant field | | |
| 2.8 | Enter client: "Acme Corp" | Text appears in client field | | |
| 2.9 | Enter notes: "Terminal B garage" | Text appears in notes field | | |
| 2.10 | Tap "Save" | Sheet dismisses, expense appears in list with merchant name and amount | | |
| 2.11 | Tap the expense row | Detail view shows all entered fields correctly | | |

---

## 3. Tag Management

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 3.1 | Tap "+" to add a new expense | New Expense form appears | | |
| 3.2 | Scroll to Tags section | Tag picker visible with "New" button | | |
| 3.3 | Tap "New" button | Inline tag creation form appears with text field | | |
| 3.4 | Type "tax-deductible" and tap "Add" | Tag chip appears in horizontal scroll, auto-selected | | |
| 3.5 | Tap "New" again, create tag "Q1-2026", tap "Add" | Second tag chip appears, both selected | | |
| 3.6 | Fill required fields (amount: 15.00, merchant: "Office Depot") and Save | Expense saved with both tags | | |
| 3.7 | Tap the expense in list | Detail view shows tag pills for both tags | | |

---

## 4. OCR Receipt Scanning

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 4.1 | Tap "Add Expense" tab | Add Expense screen with camera/photo options | | |
| 4.2 | Tap camera option | Camera permission prompt appears (first time) | | |
| 4.3 | Grant permission and photograph a receipt | Camera captures image, processing indicator shows | | |
| 4.4 | Wait for OCR processing | Manual entry form appears pre-filled with extracted data | | |
| 4.5 | Verify amount is extracted | Amount field is pre-populated (may not be 100% accurate) | | |
| 4.6 | Verify merchant is extracted | Merchant field is pre-populated | | |
| 4.7 | Verify date is extracted | Date picker shows extracted date (if found) | | |
| 4.8 | Verify receipt image appears | Receipt image visible at top of form | | |
| 4.9 | Correct any fields if needed, add category, tap Save | Expense saved with receipt image attached | | |
| 4.10 | Open the expense, tap receipt image | Full receipt image viewable | | |

**Alternative: Photo Library**
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 4.11 | Tap Add Expense, choose Photo Library | Photo picker appears | | |
| 4.12 | Select a receipt photo | OCR processes the image, form pre-fills | | |

---

## 5. Recurring Expenses

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 5.1 | Tap "+" to add new expense | New Expense form appears | | |
| 5.2 | Fill: amount 9.99, merchant "Netflix" | Fields populated | | |
| 5.3 | Scroll down and enable "Make Recurring" toggle | Toggle turns on, Frequency picker appears | | |
| 5.4 | Verify frequency defaults to "Monthly" | Monthly is selected | | |
| 5.5 | Change frequency to "Weekly" | Weekly selected | | |
| 5.6 | Change back to "Monthly" | Monthly selected | | |
| 5.7 | Tap Save | Sheet dismisses | | |
| 5.8 | Verify "Recurring" section appears in expense list | Section header "Recurring" visible with Netflix template | | |
| 5.9 | Verify regular expense also appears | "Netflix" shows in the monthly expense list with $9.99 (first occurrence) | | |
| 5.10 | Verify recurring row shows "Monthly" badge | Blue "Monthly" capsule badge visible | | |
| 5.11 | Verify recurring row shows "Next:" date | Next generation date shown (~1 month from today) | | |

---

## 6. Search and Filter

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 6.1 | Pull down on expense list to reveal search | Search bar appears | | |
| 6.2 | Type "Airport" | List filters to show only "Airport Parking" expense | | |
| 6.3 | Clear search | All expenses visible again | | |
| 6.4 | Type "Acme" | Filters by client — "Airport Parking" shows (client: Acme Corp) | | |
| 6.5 | Clear search | All expenses visible | | |
| 6.6 | Tap filter icon (top-left) | Filter sheet appears | | |
| 6.7 | Select a category filter | List updates to show only matching expenses | | |
| 6.8 | Dismiss filter, verify filter icon is filled | Filled circle icon indicates active filter | | |
| 6.9 | Re-open filter, clear selection | All expenses visible, icon returns to outline | | |

---

## 7. Reports and Export

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 7.1 | Tap "Reports" tab | Reports screen with date range, total, and category chart | | |
| 7.2 | Verify total matches sum of expenses | Total amount displayed in large bold text | | |
| 7.3 | Verify expense count shown | "X expenses" subtitle text | | |
| 7.4 | Verify category chart visible | Horizontal bar chart with category colors and amounts | | |
| 7.5 | Tap "View Full Report" | Report preview screen loads | | |
| 7.6 | Verify PDF preview shows | Formatted report with category groupings, subtotals | | |
| 7.7 | Test PDF share/export | Share sheet appears, PDF can be saved/sent | | |
| 7.8 | Test CSV export (if available on report screen) | CSV file generated, shareable | | |
| 7.9 | Open exported CSV in a spreadsheet | Columns: Date, Category, Amount, Merchant, Client, Notes, Tags | | |
| 7.10 | Verify tags appear in CSV | Tag names comma-separated in Tags column | | |

---

## 8. Settings

### 8a. Currency
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 8a.1 | Tap Settings tab → Default Currency | Currency picker appears with USD selected | | |
| 8a.2 | Search for "EUR" | Euro appears in filtered list | | |
| 8a.3 | Select EUR | Checkmark moves to EUR, navigates back | | |
| 8a.4 | Go to Expenses tab | All amounts now display with EUR symbol | | |
| 8a.5 | Return to Settings → Currency → select USD | Reset to USD for remaining tests | | |

### 8b. Category Management
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 8b.1 | Settings → Manage Categories | List of 8 default categories with icons and colors | | |
| 8b.2 | Tap "+" to add category | New Category form appears | | |
| 8b.3 | Enter name: "Subscriptions", icon: "creditcard", color: "#FF5722" | Fields populated | | |
| 8b.4 | Tap "Add" | New category appears in list | | |
| 8b.5 | Tap the new category | Edit form shows with editable fields | | |
| 8b.6 | Change name to "Digital Subscriptions" | Name updated | | |
| 8b.7 | Navigate back | Updated name shows in list | | |
| 8b.8 | Swipe to delete a category with no expenses | Category removed from list | | |

### 8c. Featured Categories
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 8c.1 | Settings → Featured Categories | List with checkmarks on 4 featured categories | | |
| 8c.2 | Deselect one, select a different category | Checkmarks update, count stays at 4 | | |
| 8c.3 | Go to Add Expense | Category picker shows updated featured categories | | |

### 8d. Tag Management
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 8d.1 | Settings → Manage Tags | List shows "tax-deductible" and "Q1-2026" tags | | |
| 8d.2 | Tap a tag | Edit form with name and color fields | | |
| 8d.3 | Change color hex | Color circle updates | | |
| 8d.4 | Navigate back | Tag shows in list with new color | | |
| 8d.5 | Tap "+" to add a tag | New Tag form appears | | |
| 8d.6 | Create tag "personal" | Tag added to list | | |

### 8e. Version
| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 8e.1 | Scroll to About section | Version shows "1.0" | | |

---

## 9. iCloud Backup & Restore

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 9.1 | Settings → Backup & Restore | Backup screen loads | | |
| 9.2 | Tap "Back Up Now" | Progress indicator shows, backup completes | | |
| 9.3 | Verify backup appears in list | Timestamped backup with expense count and size | | |
| 9.4 | Delete the app from device | App removed | | |
| 9.5 | Reinstall from TestFlight | Fresh install, onboarding appears | | |
| 9.6 | Complete onboarding | Main tab view appears (empty) | | |
| 9.7 | Go to Settings → Backup & Restore | Previous backup should be listed (from iCloud) | | |
| 9.8 | Tap Restore on the backup | Restore completes | | |
| 9.9 | Verify all expenses restored | All previously entered expenses visible with correct data | | |
| 9.10 | Verify categories restored | Custom categories (e.g., "Digital Subscriptions") present | | |
| 9.11 | Verify tags restored | All tags present with correct colors | | |
| 9.12 | Verify receipt images restored | Receipt photos viewable on expenses that had them | | |

---

## 10. Tip Jar

> **Status: DEFERRED** — In-app purchases must be submitted with the first app version for App Store review. Tip jar products will not load on TestFlight until v1.0 is submitted for review with IAPs attached.

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 10.1 | Settings → Tip Jar | Tip Jar screen loads with friendly copy | | |
| 10.2 | Verify 3 tip options display | Coffee ($0.99), Lunch ($4.99), Dinner ($9.99) — **will show empty until IAPs submitted** | | |
| 10.3 | Purchase a tip | Payment sheet appears, thank-you state after purchase | | |

---

## 11. Edge Cases & Stress Tests

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 11.1 | Add expense with $0.00 amount | Validation alert: "Please enter an amount greater than zero and a merchant name" | | |
| 11.2 | Add expense with empty merchant | Same validation alert | | |
| 11.3 | Add expense with very large amount (999999.99) | Saves and displays correctly with proper formatting | | |
| 11.4 | Add expense with very long merchant name | Text truncates gracefully in list, full text in detail | | |
| 11.5 | Swipe to delete an expense | Expense removed from list | | |
| 11.6 | Swipe to delete a recurring template | Template removed from Recurring section | | |
| 11.7 | Kill app and relaunch | All data persists, no crash | | |
| 11.8 | Rotate to landscape (iPad only) | Layout adapts, no crashes | | |
| 11.9 | Toggle Dark Mode (Settings → Display) | App renders correctly in dark mode | | |
| 11.10 | Increase text size (Settings → Accessibility → Larger Text) | Text scales, no layout breaks | | |

---

## 12. Data Integrity

| # | Step | Expected Result | Pass/Fail | Notes |
|---|------|-----------------|-----------|-------|
| 12.1 | Count total expenses in list | Matches the count shown in Reports | | |
| 12.2 | Sum amounts manually | Matches total shown in Reports | | |
| 12.3 | Verify categories in reports chart | All categories with expenses are represented | | |
| 12.4 | Verify edited expense data persists | Change a field, navigate away, come back — change saved | | |

---

## Test Summary

| Section | Total Tests | Passed | Failed | Skipped |
|---------|-----------|--------|--------|---------|
| 1. Onboarding | 9 | | | |
| 2. Manual Entry | 11 | | | |
| 3. Tags | 7 | | | |
| 4. OCR Scanning | 12 | | | |
| 5. Recurring | 11 | | | |
| 6. Search & Filter | 9 | | | |
| 7. Reports & Export | 10 | | | |
| 8. Settings | 17 | | | |
| 9. Backup & Restore | 12 | | | |
| 10. Tip Jar | 3 | | | Deferred |
| 11. Edge Cases | 10 | | | |
| 12. Data Integrity | 4 | | | |
| **TOTAL** | **115** | | | |

---

## Issues Found

| # | Section | Severity | Description | Steps to Reproduce |
|---|---------|----------|-------------|-------------------|
| | | | | |
| | | | | |
| | | | | |
