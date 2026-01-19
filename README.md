# 🌾 Farm Management System (FMS)
The **Farm Management System (FMS)** is a high-performance database solution designed to digitize and scale agricultural operations. Developed specifically for the South Asian agricultural landscape, it integrates livestock management, crop lifecycles, and financial accounting into a single source of truth.

---

## 🏗️ System Architecture

### 1. Database Design
The system is built on **Third Normal Form (3NF)** principles to ensure zero data redundancy and maximum query performance. The schema consists of **22 tables** (20 core + 2 audit).



### 2. Core Entities
* **Livestock Management:** Detailed tracking of Animals, Breeds, Milk Production, and Egg Production.
* **Crop Operations:** Management of Fields, Crop cycles (Rabi/Kharif), Irrigation, and Chemical application logs.
* **Resource & HR:** Employee management with Role-Based Access Control (RBAC) and User Accounts.
* **Financial Suite:** Customer records, Sales tracking (Sales/SalesDetails), and Expense categorization.

---

## 🛠️ Technical Excellence

### ⚡ Automated Workflows (Triggers)
The system leverages **10 intelligent triggers** to handle real-time logic:
* **Auto-Inventory:** Decrements product stock automatically upon a sale.
* **Status Automation:** Updates animal health status instantly when a veterinary log is added.
* **Audit Logging:** Captures every status change in crops and financial expenses for regulatory compliance.
* **Safety Guards:** Prevents deletion of active fields or livestock currently in production.

### 📈 Business Intelligence (Views)
**15 pre-built views** provide "at-a-glance" insights for farm managers:
* `View_FieldProductivity`: Yield analysis per acre across different seasons.
* `View_BreedPerformance`: Comparative analytics of milk/egg output by breed.
* `View_MonthlyProfit`: Automated calculation of Revenue vs. Expenses.
* `View_StockAlerts`: Real-time list of low-stock products or feed.

### 💾 Encapsulated Logic (Stored Procedures)
* `sp_RecordSale`: Handles multi-item transactions with automated tax and discount logic.
* `sp_UpdateAnimalHealth`: A unified interface for veterinary updates and status changes.
* `sp_CalculateROI`: Complex query logic to determine profitability per crop cycle.

---

## 📊 Business Impact & Use Cases
* **Commercial Dairy:** Track daily milk fat/protein quality and correlate feed costs to output.
* **Poultry Production:** Batch-based bird health tracking and egg grade documentation.
* **Organic Farming:** Detailed chemical and irrigation logs to satisfy certification requirements.
* **Supply Chain:** Manage wholesale and retail distribution with credit limit enforcement for customers.

---

## ⚙️ Technical Specifications
* **DBMS:** SQL Server 2016+ / Azure SQL
* **Data Types:** Optimized use of `DECIMAL(10,2)` for PKR currency and `DATETIME` for temporal audits.
* **Constraints:** Strict `CHECK` constraints (e.g., Salary > 0, Weight > 0, pH levels) to ensure data quality.
* **Security:** Multi-tier roles (Admin, Manager, Staff, Viewer).

---

## 🚀 Getting Started

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/Ushan256/Farm-Management-System.git](https://github.com/Ushan256/Farm-Management-System.git)
    ```
2.  **Initialize Schema**
    Run the `Farm_Management_System.sql` script in your SQL environment to build the tables and relationships.
---


**Developed by:** Ushan  
**Program:** BS Computer Science  
**Last Updated:** November 2025
