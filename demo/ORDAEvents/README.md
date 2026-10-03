# Order Management System - README

## 📋 Overview
This is a complete Order Management System built with 4D v21 with Orda Event 

---

## 🚀 Quick Start

### Prerequisites
- **4D v21 or higher** (ORDA events require v21+)
- **Operating System**: Windows, macOS, or Linux
- **Minimum RAM**: 4GB recommended

### Installation Steps


1. **Open with 4D**
   - Launch 4D application
   - File → Open → Select the project folder
   - Or double-click the `.4DProject` file

2. **First Launch**
   - The database will open automatically

---

## 📊 Database Structure

### Tables
```
┌─────────────┐
│   Client    │
├─────────────┤
│ ID          │
│ Name        │
│ Email       │
│ Phone       │
└─────────────┘

┌─────────────┐
│   Product   │
├─────────────┤
│ ID          │
│ Name        │
│ Description │
│ Price       │
│ Stock       │
│ minimumStock│
└─────────────┘

┌─────────────┐
│    Order    │
├─────────────┤
│ ID          │
│ order_number│
│ Date_Order  │
│ Date_Livr   │
│ ID_Client   │
│ Mode_Pmt    │
│ Price       │
│ Statut      │
│ Description │
└─────────────┘

┌─────────────┐
│ OrderLine   │
├─────────────┤
│ ID          │
│ ID_Order    │
│ ID_Product  │
│ Quantity    │
└─────────────┘
```


---

## 🎯 How to Use

### 1. Creating a New Order

1. **Open the Orders Form**
   - Click "New  Order" button in the main window


2. **Fill Order Details**
   - **Order number**: Auto-generated (CMD-YYYY-NNNN)
   - **Client**: Select from dropdown
   - **Date Order**: Auto-filled with today's date
   - **Delivery date**: Optional
   - **Payment method**: Select (Bank Transfer, Credit Card, etc.)
   - **Status**: Auto-set to "In progress"
   - **Description**: Optional comment

3. **Add Products**
   - Click "Add new product" button
   - A Form containig products is opened
   - Select products
   - Enter quantity
   - **Unit Price** and **Total** calculate automatically

4. **Save the Order**
   - Click the "Save" button
   - System automatically:
     - ✅ Validates stock availability
     - ✅ Calculates total order price
     - ✅ Decreases product stock
     - ✅ Saves all changes
