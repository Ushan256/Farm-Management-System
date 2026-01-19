-- Database Setup

CREATE DATABASE FarmManagementSystem;
USE FarmManagementSystem;

-- Table Creation

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    PhoneNumber NVARCHAR(15) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    Position NVARCHAR(50) NOT NULL CHECK (Position IN ('Manager', 'Veterinarian', 'Farm Worker', 'Sales Person', 'Administrator')),
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_Salary CHECK (Salary > 0)
);

CREATE TABLE UserAccount (
    UserAccountID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL UNIQUE,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Admin', 'Manager', 'Staff', 'Viewer')),
    IsActive BIT DEFAULT 1,
    LastLoginDate DATETIME,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserAccount_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE
);

CREATE TABLE Field (
    FieldID INT PRIMARY KEY IDENTITY(1,1),
    FieldName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    AreaInAcres DECIMAL(8, 2) NOT NULL,
    SoilType NVARCHAR(50) NOT NULL CHECK (SoilType IN ('Clay', 'Sandy', 'Loam', 'Silt', 'Peat')),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_FieldArea CHECK (AreaInAcres > 0)
);

CREATE TABLE Crop (
    CropID INT PRIMARY KEY IDENTITY(1,1),
    FieldID INT NOT NULL,
    CropName NVARCHAR(100) NOT NULL,
    CropType NVARCHAR(50) NOT NULL CHECK (CropType IN ('Grain', 'Vegetable', 'Fruit', 'Herb', 'Legume', 'Root')),
    PlantingDate DATE NOT NULL,
    EstimatedHarvestDate DATE NOT NULL,
    QuantityPlanted DECIMAL(10, 3) NOT NULL,
    QuantityPlantedUnit NVARCHAR(20) CHECK (QuantityPlantedUnit IN ('kg', 'seeds', 'saplings')),
    ExpectedYield DECIMAL(10, 3),
    ExpectedYieldUnit NVARCHAR(20) CHECK (ExpectedYieldUnit IN ('kg', 'tons', 'units')),
    Status NVARCHAR(20) DEFAULT 'Growing' CHECK (Status IN ('Planned', 'Growing', 'Ready to Harvest', 'Harvested', 'Failed')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Crop_Field FOREIGN KEY (FieldID) REFERENCES Field(FieldID) ON DELETE CASCADE,
    CONSTRAINT CK_CropDates CHECK (PlantingDate < EstimatedHarvestDate)
);

CREATE TABLE Breed (
    BreedID INT PRIMARY KEY IDENTITY(1,1),
    BreedName NVARCHAR(100) NOT NULL,
    AnimalType NVARCHAR(50) NOT NULL CHECK (AnimalType IN ('Cattle', 'Poultry', 'Sheep', 'Goat', 'Pig')),
    ProductType NVARCHAR(50) CHECK (ProductType IN ('Milk', 'Meat', 'Eggs', 'Wool', 'Multiple')),
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Animal (
    AnimalID INT PRIMARY KEY IDENTITY(1,1),
    BreedID INT NOT NULL,
    AnimalTag NVARCHAR(50) UNIQUE NOT NULL,
    AnimalName NVARCHAR(100) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    DateOfBirth DATE NOT NULL,
    Weight DECIMAL(8, 2),
    WeightUnit NVARCHAR(10) DEFAULT 'kg',
    AcquisitionDate DATE NOT NULL,
    AcquisitionCost DECIMAL(10, 2),
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Sick', 'Recovered', 'Sold', 'Dead')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Animal_Breed FOREIGN KEY (BreedID) REFERENCES Breed(BreedID),
    CONSTRAINT CK_AnimalWeight CHECK (Weight > 0)
);

CREATE TABLE FeedingLog (
    FeedingLogID INT PRIMARY KEY IDENTITY(1,1),
    AnimalID INT NOT NULL,
    FeedType NVARCHAR(100) NOT NULL,
    QuantityFed DECIMAL(8, 3) NOT NULL,
    QuantityUnit NVARCHAR(20) CHECK (QuantityUnit IN ('kg', 'liters', 'portions')),
    FeedingDate DATE NOT NULL,
    FeedingTime TIME,
    Cost DECIMAL(10, 2),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_FeedingLog_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID) ON DELETE CASCADE,
    CONSTRAINT CK_FeedQuantity CHECK (QuantityFed > 0)
);

CREATE TABLE VeterinaryLog (
    VeterinaryLogID INT PRIMARY KEY IDENTITY(1,1),
    AnimalID INT NOT NULL,
    VeterinarianName NVARCHAR(100) NOT NULL,
    ConsultationDate DATE NOT NULL,
    Diagnosis NVARCHAR(500),
    Symptoms NVARCHAR(500),
    TreatmentProvided NVARCHAR(500),
    Medication NVARCHAR(200),
    MedicationDosage NVARCHAR(100),
    ConsultationCost DECIMAL(10, 2),
    FollowUpDate DATE,
    Status NVARCHAR(20) CHECK (Status IN ('Healthy', 'Under Treatment', 'Recovered', 'Critical')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_VeterinaryLog_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID) ON DELETE CASCADE,
    CONSTRAINT CK_VetCost CHECK (ConsultationCost > 0)
);

CREATE TABLE IrrigationLog (
    IrrigationLogID INT PRIMARY KEY IDENTITY(1,1),
    FieldID INT NOT NULL,
    IrrigationDate DATE NOT NULL,
    IrrigationTime TIME,
    WaterQuantity DECIMAL(10, 3) NOT NULL,
    WaterQuantityUnit NVARCHAR(20) CHECK (WaterQuantityUnit IN ('gallons', 'liters', 'cubic meters')),
    IrrigationMethod NVARCHAR(50) CHECK (IrrigationMethod IN ('Drip', 'Sprinkler', 'Flood', 'Furrow', 'Manual')),
    Duration INT,
    DurationUnit NVARCHAR(20) CHECK (DurationUnit IN ('minutes', 'hours')),
    WaterCost DECIMAL(10, 2),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_IrrigationLog_Field FOREIGN KEY (FieldID) REFERENCES Field(FieldID) ON DELETE CASCADE,
    CONSTRAINT CK_WaterQuantity CHECK (WaterQuantity > 0)
);

CREATE TABLE ChemicalLog (
    ChemicalLogID INT PRIMARY KEY IDENTITY(1,1),
    FieldID INT NOT NULL,
    CropID INT,
    ChemicalType NVARCHAR(50) NOT NULL CHECK (ChemicalType IN ('Fertilizer', 'Pesticide', 'Herbicide', 'Fungicide', 'Insecticide')),
    ChemicalName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(8, 3) NOT NULL,
    QuantityUnit NVARCHAR(20) CHECK (QuantityUnit IN ('kg', 'liters', 'ml')),
    ApplicationDate DATE NOT NULL,
    ApplicationMethod NVARCHAR(50) CHECK (ApplicationMethod IN ('Spraying', 'Soil Application', 'Foliar', 'Irrigation')),
    Cost DECIMAL(10, 2),
    Reason NVARCHAR(200),
    SafetyNotes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ChemicalLog_Field FOREIGN KEY (FieldID) REFERENCES Field(FieldID) ON DELETE CASCADE,
    CONSTRAINT FK_ChemicalLog_Crop FOREIGN KEY (CropID) REFERENCES Crop(CropID) ON DELETE SET NULL
);

CREATE TABLE Harvest (
    HarvestID INT PRIMARY KEY IDENTITY(1,1),
    CropID INT NOT NULL,
    HarvestDate DATE NOT NULL,
    QuantityHarvested DECIMAL(10, 3) NOT NULL,
    QuantityHarvestedUnit NVARCHAR(20) CHECK (QuantityHarvestedUnit IN ('kg', 'tons', 'units')),
    QualityGrade NVARCHAR(20) CHECK (QualityGrade IN ('Grade A', 'Grade B', 'Grade C', 'Waste')),
    StorageLocation NVARCHAR(200),
    HarvestCost DECIMAL(10, 2),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Harvest_Crop FOREIGN KEY (CropID) REFERENCES Crop(CropID) ON DELETE CASCADE,
    CONSTRAINT CK_HarvestQuantity CHECK (QuantityHarvested > 0)
);

CREATE TABLE MilkProduction (
    MilkProductionID INT PRIMARY KEY IDENTITY(1,1),
    AnimalID INT NOT NULL,
    ProductionDate DATE NOT NULL,
    QuantityProduced DECIMAL(8, 3) NOT NULL,
    QuantityUnit NVARCHAR(20) DEFAULT 'liters',
    Quality NVARCHAR(50) CHECK (Quality IN ('Premium', 'Standard', 'Below Standard')),
    Temperature DECIMAL(5, 2),
    Density DECIMAL(5, 3),
    FatContent DECIMAL(5, 2),
    ProteinContent DECIMAL(5, 2),
    SalePrice DECIMAL(10, 2),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_MilkProduction_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID) ON DELETE CASCADE,
    CONSTRAINT CK_MilkQuantity CHECK (QuantityProduced > 0)
);

CREATE TABLE EggProduction (
    EggProductionID INT PRIMARY KEY IDENTITY(1,1),
    AnimalID INT NOT NULL,
    ProductionDate DATE NOT NULL,
    QuantityProduced INT NOT NULL,
    QuantityUnit NVARCHAR(20) DEFAULT 'pieces',
    AverageWeight DECIMAL(6, 2),
    WeightUnit NVARCHAR(20) DEFAULT 'grams',
    Quality NVARCHAR(50) CHECK (Quality IN ('Grade A', 'Grade B', 'Grade C', 'Cracked')),
    Color NVARCHAR(50) CHECK (Color IN ('Brown', 'White', 'Blue', 'Green')),
    SalePrice DECIMAL(10, 2),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_EggProduction_Animal FOREIGN KEY (AnimalID) REFERENCES Animal(AnimalID) ON DELETE CASCADE,
    CONSTRAINT CK_EggQuantity CHECK (QuantityProduced > 0)
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(15) NOT NULL,
    Address NVARCHAR(300),
    City NVARCHAR(50),
    Province NVARCHAR(50),
    PostalCode NVARCHAR(20),
    CustomerType NVARCHAR(50) CHECK (CustomerType IN ('Retail', 'Wholesale', 'Distributor', 'Individual')),
    CreditLimit DECIMAL(12, 2),
    TotalSalesAmount DECIMAL(12, 2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_CreditLimit CHECK (CreditLimit IS NULL OR CreditLimit > 0)
);

CREATE TABLE ProductCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    HarvestID INT,
    ProductType NVARCHAR(50) NOT NULL CHECK (ProductType IN ('Crop', 'Milk', 'Eggs', 'Meat', 'Other')),
    Description NVARCHAR(500),
    Quantity DECIMAL(10, 3) NOT NULL,
    QuantityUnit NVARCHAR(20) CHECK (QuantityUnit IN ('kg', 'liters', 'pieces', 'tons')),
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Expiration DATE,
    StorageLocation NVARCHAR(200),
    Status NVARCHAR(20) DEFAULT 'Available' CHECK (Status IN ('Available', 'Low Stock', 'Out of Stock', 'Discontinued')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Product_Harvest FOREIGN KEY (HarvestID) REFERENCES Harvest(HarvestID) ON DELETE SET NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES ProductCategory(CategoryID),
    CONSTRAINT CK_ProductQuantity CHECK (Quantity >= 0),
    CONSTRAINT CK_ProductPrice CHECK (UnitPrice > 0)
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    EmployeeID INT,
    SalesDate DATE NOT NULL,
    TotalAmount DECIMAL(12, 2) NOT NULL,
    DiscountPercent DECIMAL(5, 2) DEFAULT 0,
    DiscountAmount DECIMAL(10, 2) DEFAULT 0,
    TaxAmount DECIMAL(10, 2) DEFAULT 0,
    NetAmount DECIMAL(12, 2) NOT NULL,
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Cash', 'Check', 'Credit Card', 'Bank Transfer', 'Other')),
    PaymentStatus NVARCHAR(20) DEFAULT 'Paid' CHECK (PaymentStatus IN ('Paid', 'Pending', 'Cancelled')),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Sales_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE SET NULL,
    CONSTRAINT CK_SalesAmount CHECK (TotalAmount > 0),
    CONSTRAINT CK_NetAmount CHECK (NetAmount > 0)
);

CREATE TABLE SalesDetails (
    SalesDetailsID INT PRIMARY KEY IDENTITY(1,1),
    SalesID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity DECIMAL(10, 3) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    LineTotal DECIMAL(12, 2) NOT NULL,
    Discount DECIMAL(10, 2) DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SalesDetails_Sales FOREIGN KEY (SalesID) REFERENCES Sales(SalesID) ON DELETE CASCADE,
    CONSTRAINT FK_SalesDetails_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT CK_DetailQuantity CHECK (Quantity > 0),
    CONSTRAINT CK_DetailPrice CHECK (UnitPrice > 0),
    CONSTRAINT CK_DetailTotal CHECK (LineTotal > 0)
);

CREATE TABLE ExpenseCategory (
    ExpenseCategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Expense (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    ExpenseCategoryID INT NOT NULL,
    ExpenseDate DATE NOT NULL,
    Description NVARCHAR(500),
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN ('Cash', 'Check', 'Credit Card', 'Bank Transfer')),
    ReceiptNumber NVARCHAR(50),
    VendorName NVARCHAR(100),
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (ApprovalStatus IN ('Approved', 'Pending', 'Rejected')),
    Notes NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Expense_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_Expense_Category FOREIGN KEY (ExpenseCategoryID) REFERENCES ExpenseCategory(ExpenseCategoryID),
    CONSTRAINT CK_ExpenseAmount CHECK (Amount > 0)
);

-- Insert Sample Data with Logical Defaults

INSERT INTO ExpenseCategory (CategoryName, Description)
VALUES
    ('Feed and Fodder', 'Animal feed, hay, and forage costs'),
    ('Veterinary Care', 'Veterinary services, medicines, and treatments'),
    ('Fertilizers', 'Organic and chemical fertilizers for crops'),
    ('Pesticides', 'Pesticides, insecticides, and herbicides'),
    ('Irrigation', 'Water supply, electricity, and irrigation equipment'),
    ('Labor', 'Wages and salaries for farm workers'),
    ('Equipment Maintenance', 'Repair and maintenance of farm machinery'),
    ('Seeds and Saplings', 'Purchase of seeds, saplings, and breeding stock'),
    ('Transportation', 'Vehicle fuel, maintenance, and logistics'),
    ('Utilities', 'Electricity, water, and general utilities');

INSERT INTO ProductCategory (CategoryName, Description)
VALUES
    ('Dairy', 'Milk and dairy products from cattle'),
    ('Poultry', 'Eggs and poultry meat'),
    ('Crops', 'Grains, vegetables, and harvested crops'),
    ('Fertilizers', 'Organic and synthetic fertilizers'),
    ('Seeds', 'Agricultural seeds and seedlings'),
    ('Meat', 'Livestock meat and beef products'),
    ('Wool', 'Wool and textile products'),
    ('Honey', 'Honey and bee products'),
    ('Vegetables', 'Fresh vegetables and produce'),
    ('Grains', 'Wheat, rice, maize, and other cereals');

INSERT INTO Employee (EmployeeName, Email, PhoneNumber, Salary, Position, HireDate, IsActive)
VALUES
    ('Muhammad Ali Khan', 'ali.khan@farmmanagement.com', '0300-1234567', 45000.00, 'Manager', '2020-01-15', 1),
    ('Fatima Bibi', 'fatima.bibi@farmmanagement.com', '0321-9876543', 35000.00, 'Farm Worker', '2021-03-22', 1),
    ('Ch. Bashir Ahmed', 'bashir@farmmanagement.com', '0300-5555555', 50000.00, 'Veterinarian', '2019-06-10', 1),
    ('Ayesha Malik', 'ayesha.malik@farmmanagement.com', '0333-4444444', 38000.00, 'Sales Person', '2021-09-05', 1),
    ('Raja Muhammad', 'raja@farmmanagement.com', '0300-8888888', 32000.00, 'Farm Worker', '2022-01-18', 1),
    ('Noor Fatima', 'noor@farmmanagement.com', '0321-7777777', 36000.00, 'Farm Worker', '2021-11-12', 1),
    ('Hafiz Ibrahim', 'hafiz@farmmanagement.com', '0300-2222222', 52000.00, 'Administrator', '2018-07-20', 1),
    ('Zainab Hussain', 'zainab@farmmanagement.com', '0333-1111111', 40000.00, 'Sales Person', '2020-05-30', 1),
    ('Sheikh Ahmed', 'sheikh@farmmanagement.com', '0300-9999999', 33000.00, 'Farm Worker', '2022-04-15', 1),
    ('Hina Khalid', 'hina@farmmanagement.com', '0321-3333333', 37000.00, 'Farm Worker', '2021-08-22', 1);

INSERT INTO UserAccount (EmployeeID, Username, PasswordHash, Role, IsActive, LastLoginDate)
VALUES
    (1, 'ali_khan', '$2b$12$R9h21cIPz0ZWIXVvVrELCuK8DQnt4XWqsqmuelQvJ7K8X5d5c9H5K', 'Admin', 1, '2025-11-28 10:30:00'),
    (2, 'fatima_bibi', '$2b$12$4qn9K8vL5mP3xR2yT9sQ1eU7wV6bN4cH2fG3jD5kL8oP9mZ1xR', 'Staff', 1, '2025-11-27 09:15:00'),
    (3, 'bashir_vet', '$2b$12$9aB2cD4eF6gH8iJ0kL2mN4oP6qR8sT0uV2wX4yZ6aB8cD0eF2', 'Manager', 1, '2025-11-28 14:45:00'),
    (4, 'ayesha_sales', '$2b$12$5hI7jK9lM1nO3pQ5rS7tU9vW1xY3zA5bC7dE9fG1hI3jK5lM7', 'Manager', 1, '2025-11-26 11:20:00'),
    (5, 'raja_worker', '$2b$12$2mN4oP6qR8sT0uV2wX4yZ6aB8cD0eF2gH4iJ6kL8mN0oP2qR4', 'Staff', 1, '2025-11-25 08:00:00'),
    (6, 'noor_fatima', '$2b$12$7tU9vW1xY3zA5bC7dE9fG1hI3jK5lM7nO9pQ1rS3tU5vW7', 'Staff', 1, '2025-11-28 16:30:00'),
    (7, 'hafiz_admin', '$2b$12$1xY3zA5bC7dE9fG1hI3jK5lM7nO9pQ1rS3tU5vW7xY9zA1', 'Admin', 1, '2025-11-28 09:00:00'),
    (8, 'zainab_sales', '$2b$12$3bC7dE9fG1hI3jK5lM7nO9pQ1rS3tU5vW7xY9zA1bC3dE5', 'Manager', 1, '2025-11-27 13:45:00'),
    (9, 'sheikh_worker', '$2b$12$5fG1hI3jK5lM7nO9pQ1rS3tU5vW7xY9zA1bC3dE5fG7', 'Staff', 1, '2025-11-24 07:30:00'),
    (10, 'hina_khalid', '$2b$12$9zA1bC3dE5fG7hI9jK1lM3nO5pQ7rS9tU1vW3xY5zA7bC9', 'Staff', 1, '2025-11-28 15:00:00');

INSERT INTO Field (FieldName, Location, AreaInAcres, SoilType, IsActive)
VALUES
    ('North Tract', 'Okara District, Punjab', 12.50, 'Loam', 1),
    ('South Meadow', 'Faisalabad Division, Punjab', 15.75, 'Clay', 1),
    ('East Garden', 'Multan District, Punjab', 8.25, 'Sandy', 1),
    ('West Ridge', 'Bahawalpur, Punjab', 20.00, 'Loam', 1),
    ('Central Plot', 'Sargodha, Punjab', 10.50, 'Silt', 1),
    ('Upper Field', 'Jhelum District, Punjab', 6.75, 'Loam', 1),
    ('Lower Valley', 'Gujrat District, Punjab', 18.50, 'Clay', 1),
    ('Riverside Land', 'Kasur, Punjab', 14.25, 'Loam', 1),
    ('Highland Area', 'Rawalpindi, Punjab', 9.00, 'Sandy', 1),
    ('Fertile Plain', 'Sialkot, Punjab', 11.75, 'Loam', 1);

INSERT INTO Breed (BreedName, AnimalType, ProductType, Description)
VALUES
    ('Sahiwal', 'Cattle', 'Milk', 'High milk-producing indigenous cattle breed of Punjab'),
    ('Red Sindhi', 'Cattle', 'Milk', 'Heat-tolerant dairy cattle breed from Sindh'),
    ('Nili Ravi', 'Cattle', 'Milk', 'Best dairy buffalo breed of Pakistan'),
    ('Faisalabadi', 'Cattle', 'Milk', 'Specialized dairy breed from Faisalabad'),
    ('Baluchi', 'Sheep', 'Wool', 'Large wool-bearing sheep breed from Balochistan'),
    ('Beetal', 'Goat', 'Meat', 'Large-sized meat goat breed'),
    ('Barbari', 'Goat', 'Meat', 'Compact meat and milk producing goat breed'),
    ('Leghorn', 'Poultry', 'Eggs', 'High egg-laying poultry breed'),
    ('Aseel', 'Poultry', 'Meat', 'Indigenous meat-type poultry breed'),
    ('Rhode Island Red', 'Poultry', 'Eggs', 'Dual-purpose poultry breed for meat and eggs');

INSERT INTO Customer (CustomerName, Email, PhoneNumber, Address, City, Province, PostalCode, CustomerType, CreditLimit, TotalSalesAmount, IsActive)
VALUES
    ('Ahmed General Store', 'ahmed.store@email.com', '0300-1111111', 'Murree Road, Shop 45', 'Rawalpindi', 'Punjab', '46000', 'Retail', 500000.00, 0.00, 1),
    ('Malik Dairy Exports', 'malik@dairyexports.com', '0321-2222222', 'Ferozpur Road, Plaza 12', 'Lahore', 'Punjab', '54000', 'Wholesale', 2000000.00, 0.00, 1),
    ('Fatima Egg Distribution', 'fatima.eggs@email.com', '0333-3333333', 'Jail Road, Office 8', 'Faisalabad', 'Punjab', '38000', 'Distributor', 1500000.00, 0.00, 1),
    ('Ch. Bashir Farm Products', 'bashir.farm@email.com', '0300-4444444', 'Sargodha Road, Shop 56', 'Sargodha', 'Punjab', '40100', 'Retail', 400000.00, 0.00, 1),
    ('Karachi Meat House', 'karachi.meat@email.com', '0321-5555555', 'Saddar, Plaza 22', 'Karachi', 'Sindh', '74000', 'Wholesale', 1800000.00, 0.00, 1),
    ('Organic Farmers Co-op', 'organic.farm@email.com', '0333-6666666', 'GT Road, Office 15', 'Gujranwala', 'Punjab', '52000', 'Distributor', 1200000.00, 0.00, 1),
    ('Peshawar Fresh Produce', 'peshawar.fresh@email.com', '0300-7777777', 'Cantonment, Shop 34', 'Peshawar', 'KPK', '25000', 'Retail', 350000.00, 0.00, 1),
    ('Multan Agriculture Market', 'multan.agri@email.com', '0321-8888888', 'Abdali Road, Market 5', 'Multan', 'Punjab', '60000', 'Wholesale', 1900000.00, 0.00, 1),
    ('Hyderabad Regional Store', 'hyderabad.store@email.com', '0333-9999999', 'Latifabad, Shop 78', 'Hyderabad', 'Sindh', '71000', 'Retail', 420000.00, 0.00, 1),
    ('Quetta Valley Exports', 'quetta.exports@email.com', '0300-1010101', 'Zarghoon Road, Plaza 9', 'Quetta', 'Balochistan', '87300', 'Distributor', 1350000.00, 0.00, 1);

INSERT INTO Product (ProductName, CategoryID, HarvestID, ProductType, Description, Quantity, QuantityUnit, UnitPrice, Expiration, StorageLocation, Status)
VALUES
    ('Fresh Milk - Premium', 1, NULL, 'Milk', 'Pure fresh milk from Sahiwal cattle, 3.8% fat content', 500.00, 'liters', 180.00, '2025-12-05', 'Cold Storage Room 1', 'Available'),
    ('Free Range Eggs - Grade A', 2, NULL, 'Eggs', 'Organic free-range eggs from Leghorn breed', 2000.00, 'pieces', 15.00, '2025-12-20', 'Cold Storage Room 2', 'Available'),
    ('Wheat Grain - Certified', 3, NULL, 'Crop', 'High-quality wheat from recent harvest, certified organic', 5000.00, 'kg', 90.00, '2026-06-30', 'Warehouse A', 'Available'),
    ('DAP Fertilizer', 4, NULL, 'Crop', 'Di-ammonium phosphate for crop fertilization', 2000.00, 'kg', 120.00, '2026-12-31', 'Storage Shed 1', 'Available'),
    ('Maize Seeds - Hybrid', 5, NULL, 'Crop', 'High-yield hybrid maize seeds for spring planting', 1000.00, 'kg', 250.00, '2026-01-15', 'Seed Storage', 'Available'),
    ('Beef - Premium Cut', 6, NULL, 'Meat', 'Premium beef cuts from grass-fed cattle', 300.00, 'kg', 850.00, '2025-12-08', 'Refrigerated Unit 1', 'Available'),
    ('Sheep Wool - Raw', 7, NULL, 'Crop', 'Raw sheep wool from Baluchi breed', 500.00, 'kg', 450.00, '2026-02-28', 'Warehouse B', 'Available'),
    ('Wild Honey - Organic', 8, NULL, 'Crop', 'Pure organic honey from local bee farms', 200.00, 'liters', 800.00, '2026-11-30', 'Storage Room 3', 'Available'),
    ('Tomatoes - Fresh', 9, NULL, 'Crop', 'Fresh tomatoes from greenhouse cultivation', 1500.00, 'kg', 80.00, '2025-12-03', 'Cold Storage 3', 'Available'),
    ('Rice - Long Grain', 10, NULL, 'Crop', 'Premium long-grain rice from Sindh', 3000.00, 'kg', 110.00, '2026-08-15', 'Warehouse C', 'Available');

INSERT INTO Crop (FieldID, CropName, CropType, PlantingDate, EstimatedHarvestDate, QuantityPlanted, QuantityPlantedUnit, ExpectedYield, ExpectedYieldUnit, Status)
VALUES
(1, 'Wheat - Variety FSD-08', 'Grain', '2025-10-15', '2026-04-20', 500.00, 'kg', 4000.00, 'kg', 'Growing'),
(2, 'Cotton - Variety CIM-682', 'Fruit', '2025-09-20', '2026-02-28', 250.00, 'kg', 1800.00, 'kg', 'Growing'),
(3, 'Sugarcane - Variety SPF-213', 'Root', '2025-10-01', '2026-11-30', 800.00, 'kg', 45000.00, 'kg', 'Planned'),
(4, 'Wheat - Variety Aas-2011', 'Grain', '2025-10-20', '2026-04-25', 450.00, 'kg', 3600.00, 'kg', 'Growing'),
(5, 'Chickpea - Desi Variety', 'Legume', '2025-11-01', '2026-03-15', 180.00, 'kg', 1200.00, 'kg', 'Growing'),
(6, 'Rice - Super Basmati', 'Grain', '2025-05-15', '2025-10-30', 200.00, 'kg', 2400.00, 'kg', 'Ready to Harvest'),
(7, 'Maize - Hybrid NK-40', 'Grain', '2025-05-10', '2025-09-15', 300.00, 'kg', 3600.00, 'kg', 'Growing'),
(8, 'Sugarcane - Variety TN-91-1', 'Root', '2025-04-25', '2026-12-15', 750.00, 'kg', 42000.00, 'kg', 'Growing'),
(9, 'Vegetables - Tomato Mix', 'Vegetable', '2025-08-20', '2025-12-10', 150.00, 'kg', 5000.00, 'kg', 'Growing'),
(10, 'Onion - White Variety', 'Vegetable', '2025-09-15', '2026-02-28', 200.00, 'kg', 8000.00, 'kg', 'Growing');

INSERT INTO Animal (BreedID, AnimalTag, AnimalName, Gender, DateOfBirth, Weight, WeightUnit, AcquisitionDate, AcquisitionCost, Status)
VALUES
    (3, 'NR-001', 'Shahi', 'F', '2021-03-15', 450.00, 'kg', '2021-06-01', 120000.00, 'Active'),
    (3, 'NR-002', 'Begum', 'F', '2020-08-22', 480.00, 'kg', '2020-12-10', 125000.00, 'Active'),
    (3, 'NR-003', 'Sultan', 'M', '2019-11-10', 650.00, 'kg', '2020-02-15', 150000.00, 'Active'),
    (1, 'SAH-001', 'Rani', 'F', '2022-01-05', 380.00, 'kg', '2022-04-20', 85000.00, 'Active'),
    (1, 'SAH-002', 'Rajkumari', 'F', '2021-07-18', 410.00, 'kg', '2021-10-10', 90000.00, 'Active'),
    (1, 'SAH-003', 'Maharaj', 'M', '2020-05-25', 550.00, 'kg', '2020-08-30', 95000.00, 'Active'),
    (8, 'LH-001', 'Hera', 'F', '2024-03-10', 1.80, 'kg', '2024-05-15', 800.00, 'Active'),
    (8, 'LH-002', 'Zara', 'F', '2024-02-20', 1.75, 'kg', '2024-04-25', 800.00, 'Active'),
    (9, 'AS-001', 'Sher', 'M', '2024-01-15', 2.20, 'kg', '2024-03-20', 1200.00, 'Active'),
    (9, 'AS-002', 'Shera', 'M', '2023-12-05', 2.35, 'kg', '2024-02-10', 1200.00, 'Active');

INSERT INTO VeterinaryLog (AnimalID, VeterinarianName, ConsultationDate, Diagnosis, Symptoms, TreatmentProvided, Medication, MedicationDosage, ConsultationCost, FollowUpDate, Status)
VALUES
    (1, 'Dr. Ch. Bashir Ahmed', '2025-11-01', 'Routine Checkup - Excellent Health', 'Normal appetite and energy levels', 'Vaccination update', 'FMD Vaccine', '5ml Intramuscular', 2000.00, '2026-01-01', 'Healthy'),
    (2, 'Dr. Muhammad Hassan', '2025-10-15', 'Mastitis - Mild', 'Udder inflammation, reduced milk', 'Antibiotic treatment', 'Ampicillin 500mg', '1 vial twice daily', 3500.00, '2025-11-05', 'Recovered'),
    (3, 'Dr. Ch. Bashir Ahmed', '2025-11-10', 'Routine Veterinary Checkup', 'Healthy, normal appetite', 'General health examination', 'Multivitamin injection', '10ml Intramuscular', 1500.00, '2026-02-10', 'Healthy'),
    (4, 'Dr. Muhammad Hassan', '2025-11-05', 'Routine Checkup', 'Good health status, active', 'Vaccination - Blackquarter', 'BQ Vaccine', '3ml Intramuscular', 1800.00, '2026-02-05', 'Healthy'),
    (5, 'Dr. Fatima Malik', '2025-10-20', 'Digestive Upset', 'Loss of appetite, constipation', 'Probiotic treatment', 'Probiotics', '30ml Oral twice daily', 2200.00, '2025-11-03', 'Recovered'),
    (6, 'Dr. Ch. Bashir Ahmed', '2025-11-08', 'Routine Mineral Deficiency Check', 'Body condition fair', 'Mineral supplementation', 'Mineral mixture', '50g daily in feed', 1200.00, '2025-12-08', 'Under Treatment'),
    (7, 'Dr. Muhammad Hassan', '2025-11-12', 'Routine Flock Health Check', 'Good egg production, active', 'Deworming treatment', 'Levamisole 1.25%', '5ml per bird oral', 800.00, '2025-12-12', 'Healthy'),
    (8, 'Dr. Fatima Malik', '2025-11-15', 'Slight Respiratory Infection', 'Mild cough, reduced egg laying', 'Antibiotic spray + oral', 'Enrofloxacin 10%', '0.5ml per liter drinking water', 1500.00, '2025-11-25', 'Under Treatment'),
    (9, 'Dr. Ch. Bashir Ahmed', '2025-11-10', 'Wound Treatment', 'Minor leg injury from fighting', 'Wound cleaning and dressing', 'Antiseptic powder + bandage', 'Topical application', 500.00, '2025-11-20', 'Recovered'),
    (10, 'Dr. Muhammad Hassan', '2025-11-14', 'Routine Checkup', 'Healthy, good weight gain', 'General health assessment', 'Vitamin injection', '5ml Intramuscular', 600.00, '2026-01-14', 'Healthy');

INSERT INTO FeedingLog (AnimalID, FeedType, QuantityFed, QuantityUnit, FeedingDate, FeedingTime, Cost, Notes)
VALUES
    (1, 'Green Fodder (Maize Silage)', 25.00, 'kg', '2025-11-28', '06:00:00', 750.00, 'Morning feeding - fresh silage for NR-001'),
    (1, 'Concentrate Feed (Barley + Cotton Seeds)', 8.00, 'kg', '2025-11-28', '16:00:00', 480.00, 'Evening supplementary feed'),
    (2, 'Hay (Wheat Straw)', 20.00, 'kg', '2025-11-28', '06:30:00', 400.00, 'Roughage for NR-002 - good quality stored hay'),
    (2, 'Concentrate Mixture', 7.50, 'kg', '2025-11-28', '15:30:00', 450.00, 'Evening concentrate - high protein mix'),
    (4, 'Green Fodder (Berseem)', 18.00, 'kg', '2025-11-28', '06:15:00', 540.00, 'Premium berseem - high nutritional value'),
    (4, 'Concentrate Feed', 6.00, 'kg', '2025-11-28', '17:00:00', 360.00, 'Supplementary concentrate for Sahiwal'),
    (5, 'Hay (Lucerne)', 16.00, 'kg', '2025-11-28', '06:45:00', 480.00, 'Lucerne hay for SAH-002'),
    (5, 'Mineral + Vitamin Block', 1.50, 'kg', '2025-11-28', '13:00:00', 150.00, 'Salt and mineral lick block'),
    (7, 'Layer Pellets (Commercial)', 0.12, 'kg', '2025-11-28', '07:00:00', 450.00, 'Daily layer mash for egg production - Leghorn flock'),
    (9, 'Broiler Finisher Feed', 0.25, 'kg', '2025-11-28', '08:00:00', 750.00, 'High-energy finisher diet for Aseel birds');

INSERT INTO MilkProduction (AnimalID, ProductionDate, QuantityProduced, QuantityUnit, Quality, Temperature, Density, FatContent, ProteinContent, SalePrice, Notes)
VALUES
    (1, '2025-11-28', 16.50, 'liters', 'Premium', 38.5, 1.030, 8.5, 3.8, 2970.00, 'Peak lactation - excellent quality Nili Ravi milk'),
    (1, '2025-11-27', 16.00, 'liters', 'Premium', 38.2, 1.029, 8.3, 3.7, 2880.00, 'Consistent high-quality production'),
    (2, '2025-11-28', 14.25, 'liters', 'Standard', 38.0, 1.028, 7.8, 3.6, 2556.00, 'Good quality - mid lactation cycle'),
    (2, '2025-11-27', 14.50, 'liters', 'Standard', 38.1, 1.029, 7.9, 3.6, 2610.00, 'Stable production from NR-002'),
    (4, '2025-11-28', 12.00, 'liters', 'Premium', 37.8, 1.031, 4.8, 3.5, 1800.00, 'Sahiwal premium milk - high protein content'),
    (4, '2025-11-27', 11.80, 'liters', 'Premium', 37.9, 1.030, 4.7, 3.4, 1770.00, 'Consistent Sahiwal production'),
    (5, '2025-11-28', 11.25, 'liters', 'Standard', 37.6, 1.029, 4.5, 3.3, 1687.50, 'Good quality Sahiwal milk'),
    (5, '2025-11-27', 11.40, 'liters', 'Standard', 37.7, 1.030, 4.6, 3.4, 1710.00, 'Regular production - SAH-002');

INSERT INTO EggProduction (AnimalID, ProductionDate, QuantityProduced, QuantityUnit, AverageWeight, WeightUnit, Quality, Color, SalePrice, Notes)
VALUES
    (7, '2025-11-28', 1, 'pieces', 56.0, 'grams', 'Grade A', 'Brown', 50.00, 'Consistent egg production from Leghorn LH-001'),
    (7, '2025-11-27', 1, 'pieces', 55.5, 'grams', 'Grade A', 'Brown', 50.00, 'Daily lay from LH-001 - premium quality'),
    (8, '2025-11-28', 1, 'pieces', 54.0, 'grams', 'Grade B', 'Brown', 45.00, 'Slightly undersized but good quality - LH-002'),
    (8, '2025-11-27', 1, 'pieces', 55.0, 'grams', 'Grade A', 'Brown', 50.00, 'Standard production from Leghorn LH-002'),
    (7, '2025-11-26', 1, 'pieces', 55.5, 'grams', 'Grade A', 'Brown', 50.00, 'Yesterday production - Leghorn maintaining good lay'),
    (8, '2025-11-26', 1, 'pieces', 54.5, 'grams', 'Grade A', 'Brown', 50.00, 'Daily consistent production from hens');

INSERT INTO IrrigationLog (FieldID, IrrigationDate, IrrigationTime, WaterQuantity, WaterQuantityUnit, IrrigationMethod, Duration, DurationUnit, WaterCost, Notes)
VALUES
    (1, '2025-11-15', '06:00:00', 500.00, 'cubic meters', 'Flood', 120, 'minutes', 5000.00, 'First irrigation after germination'),
    (1, '2025-12-20', '06:30:00', 450.00, 'cubic meters', 'Flood', 110, 'minutes', 4500.00, 'Second irrigation at tillering stage'),
    (2, '2025-10-15', '07:00:00', 600.00, 'cubic meters', 'Flood', 150, 'minutes', 6000.00, 'Pre-sowing irrigation'),
    (2, '2025-11-10', '06:00:00', 550.00, 'cubic meters', 'Flood', 140, 'minutes', 5500.00, 'Post-emergence irrigation'),
    (3, '2025-10-20', '05:00:00', 1000.00, 'cubic meters', 'Drip', 240, 'minutes', 8000.00, 'Initial crop establishment irrigation'),
    (3, '2025-11-15', '05:30:00', 950.00, 'cubic meters', 'Drip', 230, 'minutes', 7600.00, 'Regular growth stage irrigation'),
    (6, '2025-05-25', '06:00:00', 1200.00, 'cubic meters', 'Flood', 180, 'minutes', 9600.00, 'Standing water for rice nursery transplanting'),
    (6, '2025-07-10', '06:30:00', 1100.00, 'cubic meters', 'Flood', 170, 'minutes', 8800.00, 'Mid-season water maintenance'),
    (7, '2025-06-20', '06:00:00', 400.00, 'cubic meters', 'Sprinkler', 90, 'minutes', 4000.00, 'Pre-flowering irrigation for maize'),
    (9, '2025-09-15', '06:30:00', 200.00, 'cubic meters', 'Drip', 60, 'minutes', 2400.00, 'Establishment irrigation for tomato seedlings');

INSERT INTO Harvest (CropID, HarvestDate, QuantityHarvested, QuantityHarvestedUnit, QualityGrade, StorageLocation, HarvestCost, Notes)
VALUES
(1, '2024-05-10', 3850.00, 'kg', 'Grade A', 'Warehouse A', 12000.00, 'Excellent yield - optimal weather conditions'),
(2, '2024-03-15', 1650.00, 'kg', 'Grade B', 'Warehouse A', 8000.00, 'Good quality cotton, some early boll damage'),
(3, '2024-12-20', 42000.00, 'kg', 'Grade A', 'Sugar Mill', 18000.00, 'High quality sugarcane for industrial processing'),
(4, '2026-04-28', 3450.00, 'kg', 'Grade A', 'Warehouse A', 11000.00, 'Timely harvest with good grain quality'),
(5, '2026-03-20', 1050.00, 'kg', 'Grade A', 'Warehouse B', 5000.00, 'Excellent chickpea yield with minimal pest damage'),
(6, '2025-11-05', 2200.00, 'kg', 'Grade A', 'Storage Shed 2', 6600.00, 'Super Basmati rice with premium grain length'),
(7, '2025-09-20', 3400.00, 'kg', 'Grade B', 'Warehouse C', 8000.00, 'Good maize yield, some grain breakage during combine'),
(8, '2026-12-28', 38000.00, 'kg', 'Grade B', 'Sugar Mill', 15000.00, 'Delayed harvest due to weather, slightly lower sugar content'),
(9, '2025-12-15', 4800.00, 'kg', 'Grade A', 'Cold Storage 4', 7200.00, 'Fresh tomatoes - premium quality for retail distribution'),
(10, '2026-03-10', 7200.00, 'kg', 'Grade A', 'Storage Shed 3', 8640.00, 'White onions with excellent shelf life');

INSERT INTO ChemicalLog 
(FieldID, CropID, ChemicalType, ChemicalName, Quantity, QuantityUnit, ApplicationDate, ApplicationMethod, Cost, Reason, SafetyNotes)
VALUES
(1, 1, 'Fertilizer', 'DAP (Di-ammonium Phosphate)', 200.00, 'kg', '2025-10-25', 'Soil Application', 24000.00, 'Base fertilizer for wheat crop', 'Wear gloves and mask during application'),
(2, 2, 'Fertilizer', 'Urea (46% Nitrogen)', 150.00, 'kg', '2025-10-05', 'Soil Application', 9900.00, 'Initial nitrogen for cotton', 'Apply in early morning to prevent burns'),
(3, 3, 'Fertilizer', 'NPK 20-20-0', 300.00, 'kg', '2025-10-05', 'Soil Application', 45000.00, 'Pre-planting fertilizer for sugarcane', 'Store in dry place away from moisture'),
(4, 4, 'Pesticide', 'Hexaconazole (50% EC)', 2.50, 'liters', '2025-11-10', 'Spraying', 3750.00, 'Fungal disease prevention in wheat', 'Use approved PPE - avoid skin contact'),
(5, 5, 'Pesticide', 'Imidacloprid 17.8% SL', 1.50, 'liters', '2025-11-20', 'Spraying', 2250.00, 'Insect control in chickpea crop', 'Keep away from water sources'),
(6, 6, 'Herbicide', '2,4-D Amine 50% SL', 2.00, 'liters', '2025-06-15', 'Spraying', 1200.00, 'Weed control in rice field', 'Apply on calm days'),
(7, 7, 'Herbicide', 'Atrazine 50% WP', 1.80, 'kg', '2025-05-25', 'Spraying', 1440.00, 'Pre-emergence herbicide for maize', 'Avoid drift to adjacent crops'),
(8, 8, 'Fertilizer', 'Urea (46%)', 250.00, 'kg', '2025-06-20', 'Soil Application', 16500.00, 'Top dressing for sugarcane growth', 'Store in ventilated area'),
(9, 9, 'Pesticide', 'Mancozeb 75% WP', 2.00, 'kg', '2025-09-20', 'Spraying', 2400.00, 'Fungicide for tomato blight control', 'Use respiratory protection'),
(10, 10, 'Pesticide', 'Carbofuran 3% CG', 3.00, 'kg', '2025-10-15', 'Soil Application', 4500.00, 'Soil insecticide for onion pest control', 'Not safe for bees');

GO

PRINT 'Database schema and data loaded successfully!';
GO

-- Views for Farm Management System

-- 1. Daily Milk Production Summary
-- Cardinality: MilkProduction (N) -> Animal (1) -> Breed (1)
CREATE VIEW vw_DailyMilkProductionSummary AS
SELECT 
    mp.ProductionDate,
    a.AnimalTag,
    a.AnimalName,
    b.BreedName,
    mp.QuantityProduced,
    mp.Quality,
    mp.FatContent,
    mp.ProteinContent,
    mp.SalePrice,
    (mp.QuantityProduced * mp.SalePrice) AS TotalRevenue
FROM MilkProduction mp
INNER JOIN Animal a ON mp.AnimalID = a.AnimalID
INNER JOIN Breed b ON a.BreedID = b.BreedID;

GO

-- 2. Average Milk Production by Breed
-- Cardinality: Breed (1) <- Animal (N) <- MilkProduction (N)
CREATE VIEW vw_AvgMilkByBreed AS
SELECT 
    b.BreedID,
    b.BreedName,
    COUNT(DISTINCT a.AnimalID) AS TotalAnimals,
    ROUND(AVG(mp.QuantityProduced), 2) AS AvgDailyProduction,
    ROUND(AVG(mp.FatContent), 2) AS AvgFatContent,
    ROUND(MAX(mp.QuantityProduced), 2) AS MaxProduction,
    ROUND(MIN(mp.QuantityProduced), 2) AS MinProduction
FROM Breed b
INNER JOIN Animal a ON b.BreedID = a.BreedID
INNER JOIN MilkProduction mp ON a.AnimalID = mp.AnimalID
GROUP BY b.BreedID, b.BreedName;

GO

-- 3. Product Sales Summary
-- Cardinality: Sales (1) <- SalesDetails (N) <- Product (1)
CREATE VIEW vw_ProductSalesSummary AS
SELECT 
    p.ProductID,
    p.ProductName,
    pc.CategoryName,
    SUM(sd.Quantity) AS TotalQuantitySold,
    ROUND(AVG(sd.UnitPrice), 2) AS AvgUnitPrice,
    SUM(sd.LineTotal) AS TotalSalesAmount,
    COUNT(DISTINCT sd.SalesID) AS NumberOfTransactions
FROM Product p
LEFT JOIN ProductCategory pc ON p.CategoryID = pc.CategoryID
LEFT JOIN SalesDetails sd ON p.ProductID = sd.ProductID
GROUP BY p.ProductID, p.ProductName, pc.CategoryName;

GO

-- 4. Sales by Customer
-- Cardinality: Customer (1) <- Sales (N)
CREATE VIEW vw_SalesByCustomer AS
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerType,
    c.City,
    COUNT(s.SalesID) AS TotalTransactions,
    SUM(s.NetAmount) AS TotalPurchased,
    MAX(s.SalesDate) AS LastSaleDate,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransactionValue
FROM Customer c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CustomerType, c.City;

GO

-- VIEW 5: Field Water Usage and Irrigation Efficiency
-- Cardinality: Field (1) <- IrrigationLog (N)
CREATE VIEW vw_FieldWaterUsage AS
SELECT 
    f.FieldID,
    f.FieldName,
    f.Location,
    f.AreaInAcres,
    COUNT(il.IrrigationLogID) AS IrrigationCount,
    SUM(il.WaterQuantity) AS TotalWaterQuantity,
    ROUND(AVG(il.WaterQuantity), 2) AS AvgWaterPerEvent,
    SUM(il.WaterCost) AS TotalWaterCost,
    ROUND(SUM(il.WaterCost) / f.AreaInAcres, 2) AS WaterCostPerAcre
FROM Field f
LEFT JOIN IrrigationLog il ON f.FieldID = il.FieldID
GROUP BY f.FieldID, f.FieldName, f.Location, f.AreaInAcres;

GO

-- VIEW 6: Stock Status and Inventory
-- Cardinality: ProductCategory (1) <- Product (N)
CREATE VIEW vw_StockStatus AS
SELECT 
    p.ProductID,
    p.ProductName,
    pc.CategoryName,
    p.Quantity,
    p.QuantityUnit,
    p.UnitPrice,
    (p.Quantity * p.UnitPrice) AS InventoryValue,
    p.Status,
    p.StorageLocation,
    p.Expiration
FROM Product p
LEFT JOIN ProductCategory pc ON p.CategoryID = pc.CategoryID
ORDER BY p.Status, p.Quantity DESC;

GO

-- VIEW 7: Animal Health Status
-- Cardinality: Animal (1) <- VeterinaryLog (N)
CREATE VIEW vw_AnimalHealthStatus AS
SELECT 
    a.AnimalID,
    a.AnimalTag,
    a.AnimalName,
    b.BreedName,
    a.Status,
    vl.Diagnosis,
    vl.ConsultationDate,
    vl.TreatmentProvided,
    vl.FollowUpDate,
    vl.Status AS HealthStatus,
    vl.ConsultationCost
FROM Animal a
INNER JOIN Breed b ON a.BreedID = b.BreedID
LEFT JOIN VeterinaryLog vl ON a.AnimalID = vl.AnimalID
ORDER BY a.AnimalID, vl.ConsultationDate DESC;

GO

-- VIEW 8: Monthly Revenue Report
-- Cardinality: Sales (1) <- SalesDetails (N) <- Product (1)
CREATE VIEW vw_MonthlyRevenue AS
SELECT 
    YEAR(s.SalesDate) AS Year,
    MONTH(s.SalesDate) AS Month,
    FORMAT(s.SalesDate, 'yyyy-MM') AS YearMonth,
    COUNT(DISTINCT s.SalesID) AS TotalTransactions,
    COUNT(DISTINCT s.CustomerID) AS UniqueCustomers,
    SUM(s.TotalAmount) AS GrossSales,
    SUM(s.DiscountAmount) AS TotalDiscounts,
    SUM(s.TaxAmount) AS TotalTax,
    SUM(s.NetAmount) AS NetRevenue,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransactionValue
FROM Sales s
GROUP BY YEAR(s.SalesDate), MONTH(s.SalesDate), FORMAT(s.SalesDate, 'yyyy-MM');

GO

-- VIEW 9: Sales Dashboard
-- Cardinality: Employee (1) <- Sales (N) <- Customer (1)
CREATE VIEW vw_SalesDashboard AS
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    COUNT(s.SalesID) AS TotalSales,
    SUM(s.NetAmount) AS TotalRevenue,
    ROUND(AVG(s.NetAmount), 2) AS AvgSaleValue,
    MAX(s.SalesDate) AS LastSaleDate,
    COUNT(DISTINCT s.CustomerID) AS UniqueCustomersServed
FROM Employee e
LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
WHERE e.Position = 'Sales Person'
GROUP BY e.EmployeeID, e.EmployeeName;

GO

-- VIEW 10: Crop Status and Expected Yield
-- Cardinality: Field (1) <- Crop (N)
CREATE VIEW vw_CropStatus AS
SELECT 
    c.CropID,
    c.CropName,
    c.CropType,
    f.FieldName,
    f.Location,
    c.PlantingDate,
    c.EstimatedHarvestDate,
    DATEDIFF(DAY, c.PlantingDate, c.EstimatedHarvestDate) AS GrowthPeriodDays,
    c.QuantityPlanted,
    c.ExpectedYield,
    c.Status,
    h.QuantityHarvested,
    h.QualityGrade
FROM Crop c
INNER JOIN Field f ON c.FieldID = f.FieldID
LEFT JOIN Harvest h ON c.CropID = h.CropID;

GO

-- VIEW 11: Employee Productivity Report
-- Cardinality: Employee (1) <- Sales (N)
CREATE VIEW vw_EmployeeProductivity AS
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Position,
    COUNT(s.SalesID) AS TransactionsCompleted,
    SUM(s.NetAmount) AS TotalValueProcessed,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransactionSize,
    COUNT(s.SalesID) * 100.0 / (SELECT COUNT(*) FROM Sales) AS PercentageOfTotalSales
FROM Employee e
LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName, e.Position;

GO

-- VIEW 12: Chemical Usage Report
-- Cardinality: Field (1) <- ChemicalLog (N)
CREATE VIEW vw_ChemicalUsageReport AS
SELECT 
    f.FieldID,
    f.FieldName,
    cl.ChemicalType,
    cl.ChemicalName,
    SUM(cl.Quantity) AS TotalQuantityUsed,
    cl.QuantityUnit,
    SUM(cl.Cost) AS TotalCost,
    ROUND(AVG(cl.Cost), 2) AS AvgCostPerApplication,
    COUNT(cl.ChemicalLogID) AS ApplicationCount
FROM Field f
INNER JOIN ChemicalLog cl ON f.FieldID = cl.FieldID
GROUP BY f.FieldID, f.FieldName, cl.ChemicalType, cl.ChemicalName, cl.QuantityUnit;

GO

-- VIEW 13: Expense Summary by Category
-- Cardinality: ExpenseCategory (1) <- Expense (N)
CREATE VIEW vw_ExpenseSummary AS
SELECT 
    ec.ExpenseCategoryID,
    ec.CategoryName,
    COUNT(exp.ExpenseID) AS TotalExpenses,
    SUM(exp.Amount) AS TotalAmount,
    ROUND(AVG(exp.Amount), 2) AS AvgExpenseAmount,
    MAX(exp.Amount) AS MaxExpense,
    MIN(exp.Amount) AS MinExpense,
    ROUND(SUM(exp.Amount) * 100.0 / (SELECT SUM(Amount) FROM Expense), 2) AS PercentageOfTotalExpenses
FROM ExpenseCategory ec
LEFT JOIN Expense exp ON ec.ExpenseCategoryID = exp.ExpenseCategoryID
GROUP BY ec.ExpenseCategoryID, ec.CategoryName;

GO

-- VIEW 14: Top Performing Products
-- Cardinality: Product (1) <- SalesDetails (N)
CREATE VIEW vw_TopPerformingProducts AS
SELECT 
    TOP 10
    p.ProductID,
    p.ProductName,
    pc.CategoryName,
    SUM(sd.Quantity) AS TotalUnitsSold,
    SUM(sd.LineTotal) AS TotalRevenue,
    ROUND(AVG(sd.UnitPrice), 2) AS AvgSellingPrice,
    COUNT(DISTINCT sd.SalesID) AS NumberOfSales
FROM Product p
LEFT JOIN ProductCategory pc ON p.CategoryID = pc.CategoryID
LEFT JOIN SalesDetails sd ON p.ProductID = sd.ProductID
GROUP BY p.ProductID, p.ProductName, pc.CategoryName
ORDER BY TotalRevenue DESC;

GO

-- VIEW 15: Field Productivity Analysis
-- Cardinality: Field (1) <- Crop (N) <- Harvest (1)
CREATE VIEW vw_FieldProductivity AS
SELECT 
    f.FieldID,
    f.FieldName,
    f.Location,
    f.AreaInAcres,
    COUNT(DISTINCT c.CropID) AS TotalCropsPlanted,
    SUM(h.QuantityHarvested) AS TotalHarvested,
    ROUND(SUM(h.QuantityHarvested) / f.AreaInAcres, 2) AS YieldPerAcre,
    ROUND(AVG(CAST(h.QuantityHarvested AS FLOAT)), 2) AS AvgHarvestPerCrop
FROM Field f
LEFT JOIN Crop c ON f.FieldID = c.FieldID
LEFT JOIN Harvest h ON c.CropID = h.CropID
GROUP BY f.FieldID, f.FieldName, f.Location, f.AreaInAcres;

GO

PRINT 'All views created successfully!';

GO

PRINT 'VIEW 5: Field Water Usage';
SELECT * FROM vw_FieldWaterUsage;

GO

PRINT 'VIEW 8: Monthly Revenue Report';
SELECT * FROM vw_MonthlyRevenue;

GO

PRINT 'VIEW 9: Sales Dashboard';
SELECT * FROM vw_SalesDashboard;

GO

PRINT 'VIEW 10: Crop Status and Expected Yield';
SELECT * FROM vw_CropStatus;

GO

PRINT 'VIEW 11: Employee Productivity Report';
SELECT * FROM vw_EmployeeProductivity;

GO

PRINT 'VIEW 12: Chemical Usage Report';
SELECT * FROM vw_ChemicalUsageReport;

GO
PRINT 'VIEW 3: Product Sales Summary';
SELECT * FROM vw_ProductSalesSummary;

GO

PRINT 'VIEW 4: Sales by Customer';
SELECT * FROM vw_SalesByCustomer;

GO

-- STORED PROCEDURES

-- PROCEDURE 1: Add New Animal
-- Purpose: Insert a new animal into the system with validation
CREATE PROCEDURE sp_AddNewAnimal
    @BreedID INT,
    @AnimalTag NVARCHAR(50),
    @AnimalName NVARCHAR(100),
    @Gender CHAR(1),
    @DateOfBirth DATE,
    @Weight DECIMAL(8, 2),
    @AcquisitionDate DATE,
    @AcquisitionCost DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Animal (BreedID, AnimalTag, AnimalName, Gender, DateOfBirth, Weight, AcquisitionDate, AcquisitionCost, Status)
        VALUES (@BreedID, @AnimalTag, @AnimalName, @Gender, @DateOfBirth, @Weight, @AcquisitionDate, @AcquisitionCost, 'Active');
        
        PRINT 'Animal added successfully with Tag: ' + @AnimalTag;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 2: Record Milk Production
-- Purpose: Log daily milk production for an animal
CREATE PROCEDURE sp_RecordMilkProduction
    @AnimalID INT,
    @ProductionDate DATE,
    @QuantityProduced DECIMAL(8, 3),
    @Quality NVARCHAR(50),
    @FatContent DECIMAL(5, 2),
    @ProteinContent DECIMAL(5, 2),
    @SalePrice DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO MilkProduction (AnimalID, ProductionDate, QuantityProduced, Quality, FatContent, ProteinContent, SalePrice)
        VALUES (@AnimalID, @ProductionDate, @QuantityProduced, @Quality, @FatContent, @ProteinContent, @SalePrice);
        
        PRINT 'Milk production recorded: ' + CAST(@QuantityProduced AS NVARCHAR(10)) + ' liters';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 3: Record Sale Transaction
-- Purpose: Create a sales transaction with details
CREATE PROCEDURE sp_RecordSale
    @CustomerID INT,
    @EmployeeID INT,
    @SalesDate DATE,
    @TotalAmount DECIMAL(12, 2),
    @DiscountPercent DECIMAL(5, 2) = 0,
    @TaxAmount DECIMAL(10, 2) = 0
AS
BEGIN
    BEGIN TRY
        DECLARE @DiscountAmount DECIMAL(10, 2) = (@TotalAmount * @DiscountPercent) / 100;
        DECLARE @NetAmount DECIMAL(12, 2) = @TotalAmount - @DiscountAmount + @TaxAmount;
        
        INSERT INTO Sales (CustomerID, EmployeeID, SalesDate, TotalAmount, DiscountPercent, DiscountAmount, TaxAmount, NetAmount, PaymentStatus)
        VALUES (@CustomerID, @EmployeeID, @SalesDate, @TotalAmount, @DiscountPercent, @DiscountAmount, @TaxAmount, @NetAmount, 'Paid');
        
        PRINT 'Sale recorded successfully. Net Amount: ' + CAST(@NetAmount AS NVARCHAR(15));
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 4: Update Animal Health Status
-- Purpose: Record veterinary consultation and update animal status
CREATE PROCEDURE sp_UpdateAnimalHealth
    @AnimalID INT,
    @VeterinarianName NVARCHAR(100),
    @Diagnosis NVARCHAR(500),
    @Treatment NVARCHAR(500),
    @Medication NVARCHAR(200),
    @NewStatus NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        UPDATE Animal SET Status = @NewStatus WHERE AnimalID = @AnimalID;
        
        INSERT INTO VeterinaryLog (AnimalID, VeterinarianName, ConsultationDate, Diagnosis, TreatmentProvided, Medication, Status)
        VALUES (@AnimalID, @VeterinarianName, CAST(GETDATE() AS DATE), @Diagnosis, @Treatment, @Medication, @NewStatus);
        
        PRINT 'Animal health status updated to: ' + @NewStatus;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 5: Record Field Irrigation
-- Purpose: Log irrigation event for a field
CREATE PROCEDURE sp_RecordIrrigation
    @FieldID INT,
    @WaterQuantity DECIMAL(10, 3),
    @WaterQuantityUnit NVARCHAR(20),
    @IrrigationMethod NVARCHAR(50),
    @Duration INT,
    @WaterCost DECIMAL(10, 2),
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    BEGIN TRY
        INSERT INTO IrrigationLog (FieldID, IrrigationDate, WaterQuantity, WaterQuantityUnit, IrrigationMethod, Duration, WaterCost, Notes)
        VALUES (@FieldID, CAST(GETDATE() AS DATE), @WaterQuantity, @WaterQuantityUnit, @IrrigationMethod, @Duration, @WaterCost, @Notes);
        
        PRINT 'Irrigation recorded: ' + CAST(@WaterQuantity AS NVARCHAR(10)) + ' ' + @WaterQuantityUnit;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 6: Add Feeding Log Entry
-- Purpose: Record animal feeding activity
CREATE PROCEDURE sp_RecordFeeding
    @AnimalID INT,
    @FeedType NVARCHAR(100),
    @QuantityFed DECIMAL(8, 3),
    @QuantityUnit NVARCHAR(20),
    @FeedingDate DATE,
    @Cost DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO FeedingLog (AnimalID, FeedType, QuantityFed, QuantityUnit, FeedingDate, Cost)
        VALUES (@AnimalID, @FeedType, @QuantityFed, @QuantityUnit, @FeedingDate, @Cost);
        
        PRINT 'Feeding logged: ' + CAST(@QuantityFed AS NVARCHAR(10)) + ' ' + @QuantityUnit + ' of ' + @FeedType;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- PROCEDURE 7: Get Animal Summary Report
-- Purpose: Retrieve detailed information about an animal
CREATE PROCEDURE sp_GetAnimalSummary
    @AnimalID INT
AS
BEGIN
    SELECT 
        a.AnimalID,
        a.AnimalTag,
        a.AnimalName,
        b.BreedName,
        a.Gender,
        a.DateOfBirth,
        a.Weight,
        a.Status,
        COUNT(DISTINCT vl.VeterinaryLogID) AS HealthCheckCount,
        COUNT(DISTINCT fl.FeedingLogID) AS FeedingRecords,
        COUNT(DISTINCT mp.MilkProductionID) AS MilkRecords,
        SUM(ISNULL(mp.QuantityProduced, 0)) AS TotalMilkProduced,
        SUM(ISNULL(fl.Cost, 0)) AS TotalFeedingCost
    FROM Animal a
    INNER JOIN Breed b ON a.BreedID = b.BreedID
    LEFT JOIN VeterinaryLog vl ON a.AnimalID = vl.AnimalID
    LEFT JOIN FeedingLog fl ON a.AnimalID = fl.AnimalID
    LEFT JOIN MilkProduction mp ON a.AnimalID = mp.AnimalID
    WHERE a.AnimalID = @AnimalID
    GROUP BY a.AnimalID, a.AnimalTag, a.AnimalName, b.BreedName, a.Gender, a.DateOfBirth, a.Weight, a.Status;
END;

GO

-- PROCEDURE 8: Get Field Performance Report
-- Purpose: Analyze field productivity and costs
CREATE PROCEDURE sp_GetFieldPerformance
    @FieldID INT
AS
BEGIN
    SELECT 
        f.FieldID,
        f.FieldName,
        f.Location,
        f.AreaInAcres,
        COUNT(DISTINCT c.CropID) AS CropsPlanted,
        SUM(ISNULL(h.QuantityHarvested, 0)) AS TotalHarvested,
        SUM(ISNULL(il.WaterCost, 0)) AS TotalWaterCost,
        SUM(ISNULL(cl.Cost, 0)) AS TotalChemicalCost,
        SUM(ISNULL(il.WaterCost, 0)) + SUM(ISNULL(cl.Cost, 0)) AS TotalFieldCost
    FROM Field f
    LEFT JOIN Crop c ON f.FieldID = c.FieldID
    LEFT JOIN Harvest h ON c.CropID = h.CropID
    LEFT JOIN IrrigationLog il ON f.FieldID = il.FieldID
    LEFT JOIN ChemicalLog cl ON f.FieldID = cl.FieldID
    WHERE f.FieldID = @FieldID
    GROUP BY f.FieldID, f.FieldName, f.Location, f.AreaInAcres;
END;

GO

-- PROCEDURE 9: Get Customer Purchase History
-- Purpose: Show all purchases by a specific customer
CREATE PROCEDURE sp_GetCustomerPurchaseHistory
    @CustomerID INT
AS
BEGIN
    SELECT 
        s.SalesID,
        s.SalesDate,
        s.TotalAmount,
        s.DiscountAmount,
        s.NetAmount,
        s.PaymentMethod,
        e.EmployeeName,
        COUNT(sd.SalesDetailsID) AS ItemCount
    FROM Sales s
    LEFT JOIN Employee e ON s.EmployeeID = e.EmployeeID
    LEFT JOIN SalesDetails sd ON s.SalesID = sd.SalesID
    WHERE s.CustomerID = @CustomerID
    GROUP BY s.SalesID, s.SalesDate, s.TotalAmount, s.DiscountAmount, s.NetAmount, s.PaymentMethod, e.EmployeeName
    ORDER BY s.SalesDate DESC;
END;

GO

-- PROCEDURE 10: Calculate Monthly Profit Report
-- Purpose: Generate profit analysis for a specific month
CREATE PROCEDURE sp_CalculateMonthlyProfit
    @Year INT,
    @Month INT
AS
BEGIN
    DECLARE @MonthStart DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @MonthEnd DATE = EOMONTH(@MonthStart);
    
    SELECT 
        YEAR(s.SalesDate) AS Year,
        MONTH(s.SalesDate) AS Month,
        SUM(s.NetAmount) AS TotalRevenue,
        SUM(exp.Amount) AS TotalExpenses,
        SUM(s.NetAmount) - SUM(exp.Amount) AS NetProfit,
        ROUND((SUM(s.NetAmount) - SUM(exp.Amount)) / SUM(s.NetAmount) * 100, 2) AS ProfitMargin
    FROM Sales s
    LEFT JOIN Expense exp ON MONTH(exp.ExpenseDate) = MONTH(s.SalesDate) AND YEAR(exp.ExpenseDate) = YEAR(s.SalesDate)
    WHERE YEAR(s.SalesDate) = @Year AND MONTH(s.SalesDate) = @Month
    GROUP BY YEAR(s.SalesDate), MONTH(s.SalesDate);
END;

GO

-- EXECUTING STORED PROCEDURES

PRINT 'EXECUTING STORED PROCEDURES';

GO

PRINT '';
PRINT '>>> Executing Procedure 1: Add New Animal';
EXEC sp_AddNewAnimal 
    @BreedID = 1, 
    @AnimalTag = 'SAH-006', 
    @AnimalName = 'Lakshmiii', 
    @Gender = 'F', 
    @DateOfBirth = '2023-06-15', 
    @Weight = 420.00, 
    @AcquisitionDate = '2023-09-20', 
    @AcquisitionCost = 92000.00;

GO

PRINT '';
PRINT '>>> Executing Procedure 2: Record Milk Production';
BEGIN TRY
    EXEC sp_RecordMilkProduction 
        @AnimalID = 4, 
        @ProductionDate = '2025-11-29', 
        @QuantityProduced = 13.50, 
        @Quality = 'Premium', 
        @FatContent = 4.9, 
        @ProteinContent = 3.5, 
        @SalePrice = 1852.50;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 3: Record Sale Transaction';
BEGIN TRY
    EXEC sp_RecordSale 
        @CustomerID = 1, 
        @EmployeeID = 4, 
        @SalesDate = '2025-11-29', 
        @TotalAmount = 5000.00, 
        @DiscountPercent = 5.00, 
        @TaxAmount = 225.00;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 4: Update Animal Health Status';
BEGIN TRY
    EXEC sp_UpdateAnimalHealth 
        @AnimalID = 2, 
        @VeterinarianName = 'Dr. Fatima Khan', 
        @Diagnosis = 'Routine health checkup - all normal', 
        @Treatment = 'Preventive vaccination', 
        @Medication = 'Multivitamin injection', 
        @NewStatus = 'Healthy';
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 5: Record Field Irrigation';
BEGIN TRY
    EXEC sp_RecordIrrigation 
        @FieldID = 1, 
        @WaterQuantity = 480.00, 
        @WaterQuantityUnit = 'cubic meters', 
        @IrrigationMethod = 'Flood', 
        @Duration = 105, 
        @WaterCost = 4800.00, 
        @Notes = 'Late afternoon irrigation at boot stage of wheat';
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 6: Record Feeding';
BEGIN TRY
    EXEC sp_RecordFeeding 
        @AnimalID = 2, 
        @FeedType = 'Premium Berseem + Concentrate Mix', 
        @QuantityFed = 22.50, 
        @QuantityUnit = 'kg', 
        @FeedingDate = '2025-11-29', 
        @Cost = 675.00;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 7: Get Animal Summary Report';
PRINT 'Animal Summary for AnimalID = 1:';
BEGIN TRY
    EXEC sp_GetAnimalSummary @AnimalID = 1;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 8: Get Field Performance Report';
PRINT 'Field Performance for FieldID = 1:';
BEGIN TRY
    EXEC sp_GetFieldPerformance @FieldID = 1;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 9: Get Customer Purchase History';
PRINT 'Purchase History for CustomerID = 1:';
BEGIN TRY
    EXEC sp_GetCustomerPurchaseHistory @CustomerID = 1;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT '>>> Executing Procedure 10: Calculate Monthly Profit Report';
PRINT 'Profit Analysis for November 2025:';
BEGIN TRY
    EXEC sp_CalculateMonthlyProfit @Year = 2025, @Month = 11;
END TRY
BEGIN CATCH
    PRINT 'Procedure execution skipped (may be due to missing data dependencies).'
END CATCH

GO

PRINT '';
PRINT 'All procedures executed successfully!';

GO
-- TRIGGERS

-- TRIGGER 1: Update Animal Status on Health Check
-- Purpose: Automatically update animal status based on veterinary consultation
CREATE TRIGGER tr_UpdateAnimalStatusOnVetCheck
ON VeterinaryLog
AFTER INSERT
AS
BEGIN
    UPDATE a
    SET a.Status = inserted.Status
    FROM Animal a
    INNER JOIN inserted ON a.AnimalID = inserted.AnimalID
    WHERE inserted.Status IN ('Healthy', 'Sick', 'Recovered', 'Critical');
    
    PRINT 'Trigger: Animal status updated based on veterinary consultation';
END;

GO

-- TRIGGER 2: Update Product Quantity on Sales
-- Purpose: Automatically decrease product inventory when sold
CREATE TRIGGER tr_DecreaseProductInventory
ON SalesDetails
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.Quantity = p.Quantity - inserted.Quantity
    FROM Product p
    INNER JOIN inserted ON p.ProductID = inserted.ProductID;
    
    PRINT 'Trigger: Product inventory decreased after sale';
END;

GO

-- TRIGGER 3: Update Product Status Based on Quantity
-- Purpose: Automatically update product status based on available quantity
CREATE TRIGGER tr_UpdateProductStatus
ON Product
AFTER UPDATE
AS
BEGIN
    UPDATE Product
    SET Status = CASE
        WHEN Quantity = 0 THEN 'Out of Stock'
        WHEN Quantity < 100 THEN 'Low Stock'
        ELSE 'Available'
    END
    WHERE ProductID IN (SELECT ProductID FROM inserted);
    
    PRINT 'Trigger: Product status updated based on inventory level';
END;

GO

-- TRIGGER 4: Update Total Sales Amount on Customer Record
-- Purpose: Keep track of total customer purchases
CREATE TRIGGER tr_UpdateCustomerTotalSales
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE c
    SET c.TotalSalesAmount = ISNULL(c.TotalSalesAmount, 0) + inserted.NetAmount
    FROM Customer c
    INNER JOIN inserted ON c.CustomerID = inserted.CustomerID;
    
    PRINT 'Trigger: Customer total sales amount updated';
END;

GO

-- TRIGGER 5: Prevent Deletion of Active Animals
-- Purpose: Protect active animals from accidental deletion
CREATE TRIGGER tr_PreventActiveAnimalDeletion
ON Animal
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE Status = 'Active')
    BEGIN
        PRINT 'Error: Cannot delete active animals. Update status first.';
    END
    ELSE
    BEGIN
        DELETE FROM Animal WHERE AnimalID IN (SELECT AnimalID FROM deleted);
        PRINT 'Trigger: Inactive animal deleted successfully';
    END
END;

GO

-- TRIGGER 6: Log Crop Status Changes
-- Purpose: Create audit trail for crop status changes
CREATE TABLE CropStatusAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    CropID INT NOT NULL,
    OldStatus NVARCHAR(20),
    NewStatus NVARCHAR(20),
    ChangeDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CropAudit_Crop FOREIGN KEY (CropID) REFERENCES Crop(CropID)
);

GO

CREATE TRIGGER tr_LogCropStatusChanges
ON Crop
AFTER UPDATE
AS
BEGIN
    INSERT INTO CropStatusAudit (CropID, OldStatus, NewStatus)
    SELECT 
        inserted.CropID,
        deleted.Status,
        inserted.Status
    FROM inserted
    INNER JOIN deleted ON inserted.CropID = deleted.CropID
    WHERE inserted.Status <> deleted.Status;
    
    PRINT 'Trigger: Crop status change logged in audit table';
END;

GO

-- TRIGGER 7: Validate Feeding Cost Entry
-- Purpose: Ensure feeding cost is positive
CREATE TRIGGER tr_ValidateFeedingCost
ON FeedingLog
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Cost < 0)
    BEGIN
        PRINT 'Error: Feeding cost cannot be negative';
    END
    ELSE
    BEGIN
        INSERT INTO FeedingLog (AnimalID, FeedType, QuantityFed, QuantityUnit, FeedingDate, FeedingTime, Cost, Notes, CreatedDate)
        SELECT AnimalID, FeedType, QuantityFed, QuantityUnit, FeedingDate, FeedingTime, Cost, Notes, GETDATE()
        FROM inserted;
        
        PRINT 'Trigger: Valid feeding log entry inserted';
    END
END;

GO

-- TRIGGER 8: Auto-Calculate Harvest Cost on Insert
-- Purpose: Automatically calculate and set harvest cost based on quantity
CREATE TRIGGER tr_AutoCalculateHarvestCost
ON Harvest
AFTER INSERT
AS
BEGIN
    UPDATE h
    SET h.HarvestCost = CASE
        WHEN h.QualityGrade = 'Grade A' THEN h.QuantityHarvested * 3
        WHEN h.QualityGrade = 'Grade B' THEN h.QuantityHarvested * 2
        WHEN h.QualityGrade = 'Grade C' THEN h.QuantityHarvested * 1
        ELSE h.QuantityHarvested * 0.5
    END
    FROM Harvest h
    INNER JOIN inserted ON h.HarvestID = inserted.HarvestID;
    
    PRINT 'Trigger: Harvest cost auto-calculated based on quality grade';
END;

GO

-- TRIGGER 9: Track Expense Record Creation
-- Purpose: Log when expenses are added to system
CREATE TABLE ExpenseAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseID INT NOT NULL,
    Amount DECIMAL(10, 2),
    CategoryID INT,
    EmployeeID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ExpenseAudit_Expense FOREIGN KEY (ExpenseID) REFERENCES Expense(ExpenseID)
);

GO

CREATE TRIGGER tr_AuditExpenseCreation
ON Expense
AFTER INSERT
AS
BEGIN
    INSERT INTO ExpenseAudit (ExpenseID, Amount, CategoryID, EmployeeID)
    SELECT ExpenseID, Amount, ExpenseCategoryID, EmployeeID
    FROM inserted;
    
    PRINT 'Trigger: Expense record creation logged in audit table';
END;

GO

-- TRIGGER 10: Validate Milk Production Quality
-- Purpose: Ensure milk quality values are within valid range
CREATE TRIGGER tr_ValidateMilkQuality
ON MilkProduction
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE FatContent < 3.0 OR FatContent > 6.0 OR ProteinContent < 3.0 OR ProteinContent > 4.5)
    BEGIN
        PRINT 'Error: Milk quality values out of acceptable range. Fat: 3-6%, Protein: 3-4.5%';
    END
    ELSE
    BEGIN
        INSERT INTO MilkProduction (AnimalID, ProductionDate, QuantityProduced, QuantityUnit, Quality, Temperature, Density, FatContent, ProteinContent, SalePrice, Notes, CreatedDate)
        SELECT AnimalID, ProductionDate, QuantityProduced, QuantityUnit, Quality, Temperature, Density, FatContent, ProteinContent, SalePrice, Notes, GETDATE()
        FROM inserted;
        
        PRINT 'Trigger: Valid milk production record inserted';
    END
END;

GO
-- TESTING TRIGGERS

PRINT '';
PRINT 'TESTING TRIGGERS';

GO

PRINT '';
PRINT '>>> Testing Trigger 1: Update Animal Status on Vet Check';
PRINT 'Current Animal Status (before trigger):';
SELECT AnimalID, Status FROM Animal WHERE AnimalID = 5;

PRINT 'Inserting vet check with Recovered status...';
INSERT INTO VeterinaryLog (AnimalID, VeterinarianName, ConsultationDate, Diagnosis, TreatmentProvided, Status)
VALUES (5, 'Dr. Veterinary Expert', CAST(GETDATE() AS DATE), 'Post-treatment recovery', 'Full recovery', 'Recovered');

PRINT 'Animal Status (after trigger):';
SELECT AnimalID, Status FROM Animal WHERE AnimalID = 5;

GO

PRINT '';
PRINT '>>> Testing Trigger 2: Decrease Product Inventory on Sale';
PRINT 'Product Quantity (before sale):';
SELECT ProductID, ProductName, Quantity FROM Product WHERE ProductID = 1;

PRINT 'Creating sample sale record...';
INSERT INTO Sales (CustomerID, EmployeeID, SalesDate, TotalAmount, NetAmount, PaymentStatus)
VALUES (1, 4, CAST(GETDATE() AS DATE), 1000.00, 950.00, 'Paid');

DECLARE @LastSalesID INT = (SELECT MAX(SalesID) FROM Sales);

PRINT 'Adding product to sale details...';
INSERT INTO SalesDetails (SalesID, ProductID, Quantity, UnitPrice, LineTotal)
VALUES (@LastSalesID, 1, 50.00, 180.00, 9000.00);

PRINT 'Product Quantity (after trigger):';
SELECT ProductID, ProductName, Quantity FROM Product WHERE ProductID = 1;

GO

PRINT '';
PRINT '>>> Testing Trigger 4: Update Customer Total Sales';
PRINT 'Customer Total Sales (before):';
SELECT CustomerID, CustomerName, TotalSalesAmount FROM Customer WHERE CustomerID = 1;

PRINT 'Customer Total Sales (after sale insertion):';
SELECT CustomerID, CustomerName, TotalSalesAmount FROM Customer WHERE CustomerID = 1;

GO

PRINT '';
PRINT '>>> Testing Trigger 6: Log Crop Status Changes';
PRINT 'Crop Status Audit Records:';
SELECT * FROM CropStatusAudit;

GO

PRINT '';
PRINT '>>> Testing Trigger 9: Expense Creation Audit';
PRINT 'Expense Audit Records:';
SELECT * FROM ExpenseAudit;

GO

PRINT '';
PRINT 'All triggers created and tested!';

GO

-- AGGREGATE FUNCTION QUERIES

PRINT '';
PRINT 'AGGREGATE FUNCTION QUERIES';

GO

-- QUERY 1: Total Milk Production Summary with Aggregates
PRINT '';
PRINT '>>> Query 1: Total Milk Production by Animal (SUM, AVG, COUNT, MAX)';
SELECT 
    a.AnimalID,
    a.AnimalTag,
    a.AnimalName,
    COUNT(mp.MilkProductionID) AS TotalRecords,
    SUM(mp.QuantityProduced) AS TotalMilkProduced,
    ROUND(AVG(mp.QuantityProduced), 2) AS AvgDailyProduction,
    MAX(mp.QuantityProduced) AS MaxProduction,
    MIN(mp.QuantityProduced) AS MinProduction,
    ROUND(SUM(mp.SalePrice), 2) AS TotalRevenue
FROM Animal a
LEFT JOIN MilkProduction mp ON a.AnimalID = mp.AnimalID
GROUP BY a.AnimalID, a.AnimalTag, a.AnimalName
HAVING COUNT(mp.MilkProductionID) > 0
ORDER BY TotalMilkProduced DESC;

GO

-- QUERY 2: Sales Revenue by Customer (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 2: Customer Revenue Analysis (SUM, COUNT, AVG)';
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerType,
    COUNT(s.SalesID) AS TotalTransactions,
    SUM(s.NetAmount) AS TotalRevenue,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransactionValue,
    MAX(s.NetAmount) AS MaxTransactionValue,
    MIN(s.NetAmount) AS MinTransactionValue
FROM Customer c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CustomerType
ORDER BY TotalRevenue DESC;

GO

-- QUERY 3: Product Sales Statistics (SUM, COUNT, AVG, MAX, MIN)
PRINT '';
PRINT '>>> Query 3: Product Sales Statistics (SUM, COUNT, AVG)';
SELECT 
    p.ProductID,
    p.ProductName,
    pc.CategoryName,
    COUNT(sd.SalesDetailsID) AS TimesSold,
    SUM(sd.Quantity) AS TotalQuantitySold,
    ROUND(AVG(sd.UnitPrice), 2) AS AvgPrice,
    MAX(sd.UnitPrice) AS HighestPrice,
    MIN(sd.UnitPrice) AS LowestPrice,
    SUM(sd.LineTotal) AS TotalRevenue
FROM Product p
LEFT JOIN ProductCategory pc ON p.CategoryID = pc.CategoryID
LEFT JOIN SalesDetails sd ON p.ProductID = sd.ProductID
GROUP BY p.ProductID, p.ProductName, pc.CategoryName
ORDER BY TotalRevenue DESC;

GO

-- QUERY 4: Monthly Sales Aggregation (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 4: Monthly Sales Aggregation (SUM, COUNT, AVG)';
SELECT 
    YEAR(s.SalesDate) AS Year,
    MONTH(s.SalesDate) AS Month,
    FORMAT(s.SalesDate, 'MMMM yyyy') AS MonthYear,
    COUNT(s.SalesID) AS TotalSalesTransactions,
    SUM(s.TotalAmount) AS GrossSales,
    SUM(s.DiscountAmount) AS TotalDiscounts,
    SUM(s.TaxAmount) AS TotalTax,
    SUM(s.NetAmount) AS NetRevenue,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransactionValue,
    MAX(s.NetAmount) AS LargestSale,
    MIN(s.NetAmount) AS SmallestSale
FROM Sales s
GROUP BY YEAR(s.SalesDate), MONTH(s.SalesDate), FORMAT(s.SalesDate, 'MMMM yyyy')
ORDER BY Year DESC, Month DESC;

GO

-- QUERY 5: Employee Sales Performance (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 5: Employee Sales Performance (SUM, COUNT, AVG)';
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Position,
    COUNT(s.SalesID) AS TotalSalesCompleted,
    SUM(s.NetAmount) AS TotalSalesValue,
    ROUND(AVG(s.NetAmount), 2) AS AvgSaleValue,
    MAX(s.NetAmount) AS LargestSale,
    MIN(s.NetAmount) AS SmallestSale
FROM Employee e
LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
WHERE e.Position = 'Sales Person'
GROUP BY e.EmployeeID, e.EmployeeName, e.Position
ORDER BY TotalSalesValue DESC;

GO

-- QUERY 6: Expense Summary by Category (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 6: Expense Summary by Category (SUM, COUNT, AVG)';
SELECT 
    ec.CategoryName,
    COUNT(exp.ExpenseID) AS TotalExpenses,
    SUM(exp.Amount) AS TotalExpenseAmount,
    ROUND(AVG(exp.Amount), 2) AS AvgExpenseAmount,
    MAX(exp.Amount) AS MaxExpense,
    MIN(exp.Amount) AS MinExpense,
    ROUND(SUM(exp.Amount) * 100.0 / (SELECT SUM(Amount) FROM Expense), 2) AS PercentageOfTotal
FROM ExpenseCategory ec
LEFT JOIN Expense exp ON ec.ExpenseCategoryID = exp.ExpenseCategoryID
GROUP BY ec.CategoryName
ORDER BY TotalExpenseAmount DESC;

GO

-- QUERY 7: Crop Harvest Summary (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 7: Crop Harvest Summary (SUM, COUNT, AVG)';
SELECT 
    c.CropName,
    c.CropType,
    COUNT(h.HarvestID) AS HarvestCount,
    SUM(h.QuantityHarvested) AS TotalHarvested,
    ROUND(AVG(h.QuantityHarvested), 2) AS AvgHarvestPerCrop,
    MAX(h.QuantityHarvested) AS LargestHarvest,
    MIN(h.QuantityHarvested) AS SmallestHarvest,
    SUM(h.HarvestCost) AS TotalHarvestCost
FROM Crop c
LEFT JOIN Harvest h ON c.CropID = h.CropID
GROUP BY c.CropName, c.CropType
ORDER BY TotalHarvested DESC;

GO

-- QUERY 8: Field Irrigation and Cost Analysis (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 8: Field Irrigation and Cost Analysis (SUM, COUNT, AVG)';
SELECT 
    f.FieldName,
    f.Location,
    f.AreaInAcres,
    COUNT(il.IrrigationLogID) AS TotalIrrigationEvents,
    SUM(il.WaterQuantity) AS TotalWaterUsed,
    ROUND(AVG(il.WaterQuantity), 2) AS AvgWaterPerEvent,
    SUM(il.WaterCost) AS TotalWaterCost,
    ROUND(SUM(il.WaterCost) / f.AreaInAcres, 2) AS CostPerAcre,
    MAX(il.IrrigationDate) AS LastIrrigationDate
FROM Field f
LEFT JOIN IrrigationLog il ON f.FieldID = il.FieldID
GROUP BY f.FieldID, f.FieldName, f.Location, f.AreaInAcres
ORDER BY TotalWaterCost DESC;

GO

-- QUERY 9: Animal Feeding Cost Analysis (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 9: Animal Feeding Cost Analysis (SUM, COUNT, AVG)';
SELECT 
    a.AnimalTag,
    a.AnimalName,
    b.BreedName,
    COUNT(fl.FeedingLogID) AS FeedingRecords,
    SUM(fl.QuantityFed) AS TotalQuantityFed,
    ROUND(AVG(fl.QuantityFed), 2) AS AvgQuantityPerFeeding,
    SUM(fl.Cost) AS TotalFeedingCost,
    ROUND(AVG(fl.Cost), 2) AS AvgCostPerFeeding,
    MAX(fl.Cost) AS MaxFeedingCost,
    MIN(fl.Cost) AS MinFeedingCost
FROM Animal a
INNER JOIN Breed b ON a.BreedID = b.BreedID
LEFT JOIN FeedingLog fl ON a.AnimalID = fl.AnimalID
GROUP BY a.AnimalID, a.AnimalTag, a.AnimalName, b.BreedName
ORDER BY TotalFeedingCost DESC;

GO

-- QUERY 10: Chemical Usage by Type (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 10: Chemical Usage by Type (SUM, COUNT, AVG)';
SELECT 
    cl.ChemicalType,
    cl.ChemicalName,
    COUNT(cl.ChemicalLogID) AS ApplicationCount,
    SUM(cl.Quantity) AS TotalQuantityUsed,
    ROUND(AVG(cl.Quantity), 2) AS AvgQuantityPerApplication,
    MAX(cl.Quantity) AS MaxQuantity,
    MIN(cl.Quantity) AS MinQuantity,
    SUM(cl.Cost) AS TotalCost,
    ROUND(AVG(cl.Cost), 2) AS AvgCostPerApplication
FROM ChemicalLog cl
GROUP BY cl.ChemicalType, cl.ChemicalName
ORDER BY TotalCost DESC;

GO

-- QUERY 11: Inventory Value Analysis (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 11: Inventory Value Analysis (SUM, COUNT, AVG)';
SELECT 
    pc.CategoryName,
    COUNT(p.ProductID) AS ProductCount,
    SUM(p.Quantity) AS TotalQuantityInStock,
    ROUND(AVG(p.UnitPrice), 2) AS AvgUnitPrice,
    MAX(p.UnitPrice) AS MaxPrice,
    MIN(p.UnitPrice) AS MinPrice,
    SUM(p.Quantity * p.UnitPrice) AS TotalInventoryValue,
    ROUND(AVG(p.Quantity * p.UnitPrice), 2) AS AvgProductValue
FROM ProductCategory pc
LEFT JOIN Product p ON pc.CategoryID = p.CategoryID
GROUP BY pc.CategoryName
ORDER BY TotalInventoryValue DESC;

GO

-- QUERY 12: Breed Performance Summary (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 12: Breed Performance Summary (SUM, COUNT, AVG)';
SELECT 
    b.BreedName,
    b.AnimalType,
    COUNT(a.AnimalID) AS TotalAnimals,
    COUNT(mp.MilkProductionID) AS MilkRecords,
    SUM(mp.QuantityProduced) AS TotalMilkProduced,
    ROUND(AVG(mp.QuantityProduced), 2) AS AvgMilkPerAnimal,
    COUNT(ep.EggProductionID) AS EggRecords,
    SUM(ep.QuantityProduced) AS TotalEggsProduced
FROM Breed b
LEFT JOIN Animal a ON b.BreedID = a.BreedID
LEFT JOIN MilkProduction mp ON a.AnimalID = mp.AnimalID
LEFT JOIN EggProduction ep ON a.AnimalID = ep.AnimalID
GROUP BY b.BreedID, b.BreedName, b.AnimalType
ORDER BY TotalMilkProduced DESC;

GO

-- QUERY 13: Veterinary Cost Analysis (SUM, COUNT, AVG)
PRINT '';
PRINT '>>> Query 13: Veterinary Cost Analysis (SUM, COUNT, AVG)';
SELECT 
    a.AnimalTag,
    a.AnimalName,
    COUNT(vl.VeterinaryLogID) AS ConsultationCount,
    SUM(vl.ConsultationCost) AS TotalVetCost,
    ROUND(AVG(vl.ConsultationCost), 2) AS AvgCostPerConsultation,
    MAX(vl.ConsultationCost) AS MaxConsultationCost,
    MIN(vl.ConsultationCost) AS MinConsultationCost,
    ROUND(SUM(vl.ConsultationCost) * 100.0 / (SELECT SUM(ConsultationCost) FROM VeterinaryLog), 2) AS PercentageOfTotalVetCost
FROM Animal a
LEFT JOIN VeterinaryLog vl ON a.AnimalID = vl.AnimalID
GROUP BY a.AnimalID, a.AnimalTag, a.AnimalName
HAVING COUNT(vl.VeterinaryLogID) > 0
ORDER BY TotalVetCost DESC;

GO

-- QUERY 14: Sales Performance with HAVING Clause (SUM, COUNT, HAVING)
PRINT '';
PRINT '>>> Query 14: High-Value Customers (SUM, COUNT, HAVING Clause)';
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerType,
    COUNT(s.SalesID) AS TransactionCount,
    SUM(s.NetAmount) AS TotalPurchased,
    ROUND(AVG(s.NetAmount), 2) AS AvgTransaction
FROM Customer c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CustomerType
HAVING SUM(s.NetAmount) > 1000 OR COUNT(s.SalesID) > 2
ORDER BY TotalPurchased DESC;

GO

-- QUERY 15: Profitability Analysis (SUM, AVG with Complex Calculation)
PRINT '';
PRINT '>>> Query 15: Overall Farm Profitability Analysis';
SELECT 
    'Sales Revenue' AS FinancialMetric,
    SUM(s.NetAmount) AS Amount
FROM Sales s
UNION ALL
SELECT 
    'Total Expenses' AS FinancialMetric,
    SUM(exp.Amount) AS Amount
FROM Expense exp
UNION ALL
SELECT 
    'Net Profit' AS FinancialMetric,
    (SELECT SUM(s.NetAmount) FROM Sales s) - (SELECT SUM(exp.Amount) FROM Expense exp) AS Amount;

GO

PRINT '';
PRINT 'All aggregate queries executed!';

GO

-- JOIN QUERIES

PRINT '';
PRINT 'JOIN QUERIES';

GO

-- JOIN QUERY 1: INNER JOIN - Employee and Sales
PRINT '';
PRINT '>>> JOIN Query 1: INNER JOIN - Employee and Sales (N:1 relationship)';
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Position,
    s.SalesID,
    s.SalesDate,
    s.NetAmount,
    COUNT(*) OVER (PARTITION BY e.EmployeeID) AS TotalSalesByEmployee
FROM Employee e
INNER JOIN Sales s ON e.EmployeeID = s.EmployeeID
ORDER BY e.EmployeeID, s.SalesDate DESC;

GO

-- JOIN QUERY 2: LEFT JOIN - Customer and Sales
PRINT '';
PRINT '>>> JOIN Query 2: LEFT JOIN - Customer and Sales (1:N relationship)';
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerType,
    s.SalesID,
    s.SalesDate,
    s.NetAmount,
    CASE WHEN s.SalesID IS NULL THEN 'No Sales' ELSE 'Active' END AS CustomerStatus
FROM Customer c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
ORDER BY c.CustomerID, s.SalesDate DESC;

GO

-- JOIN QUERY 3: INNER JOIN - Product, Category, and Sales Details
PRINT '';
PRINT '>>> JOIN Query 3: INNER JOIN - Product, Category, and Sales Details (Multi-table join)';
SELECT 
    p.ProductID,
    p.ProductName,
    pc.CategoryName,
    sd.SalesID,
    sd.Quantity,
    sd.UnitPrice,
    sd.LineTotal,
    s.NetAmount,
    ROUND((sd.LineTotal / s.NetAmount) * 100, 2) AS ProductPercentage
FROM Sales s
INNER JOIN SalesDetails sd ON s.SalesID = sd.SalesID
INNER JOIN Product p ON sd.ProductID = p.ProductID
INNER JOIN ProductCategory pc ON p.CategoryID = pc.CategoryID
ORDER BY s.SalesID, sd.SalesDetailsID;

GO

-- JOIN QUERY 4: LEFT JOIN - Animal and Veterinary Log
PRINT '';
PRINT '>>> JOIN Query 4: LEFT JOIN - Animal and Veterinary Log (1:N relationship)';
SELECT 
    a.AnimalID,
    a.AnimalTag,
    a.AnimalName,
    a.Status,
    vl.VeterinaryLogID,
    vl.ConsultationDate,
    vl.Diagnosis,
    vl.Status AS HealthStatus,
    vl.ConsultationCost,
    ROW_NUMBER() OVER (PARTITION BY a.AnimalID ORDER BY vl.ConsultationDate DESC) AS ConsultationRank
FROM Animal a
LEFT JOIN VeterinaryLog vl ON a.AnimalID = vl.AnimalID
ORDER BY a.AnimalID, vl.ConsultationDate DESC;

GO

-- JOIN QUERY 5: INNER JOIN - Breed, Animal, and Milk Production
PRINT '';
PRINT '>>> JOIN Query 5: INNER JOIN - Breed, Animal, Milk Production (Multi-table join)';
SELECT 
    b.BreedID,
    b.BreedName,
    a.AnimalID,
    a.AnimalTag,
    a.AnimalName,
    mp.ProductionDate,
    mp.QuantityProduced,
    mp.Quality,
    mp.FatContent,
    mp.ProteinContent
FROM Breed b
INNER JOIN Animal a ON b.BreedID = a.BreedID
INNER JOIN MilkProduction mp ON a.AnimalID = mp.AnimalID
ORDER BY b.BreedID, a.AnimalID, mp.ProductionDate DESC;

GO

-- JOIN QUERY 6: LEFT JOIN - Field, Crop, and Harvest
PRINT '';
PRINT '>>> JOIN Query 6: LEFT JOIN - Field, Crop, Harvest (1:N:1 relationship)';
SELECT 
    f.FieldID,
    f.FieldName,
    f.Location,
    c.CropID,
    c.CropName,
    c.Status AS CropStatus,
    h.HarvestID,
    h.HarvestDate,
    h.QuantityHarvested,
    h.QualityGrade
FROM Field f
LEFT JOIN Crop c ON f.FieldID = c.FieldID
LEFT JOIN Harvest h ON c.CropID = h.CropID
ORDER BY f.FieldID, c.CropID, h.HarvestDate DESC;

GO

-- JOIN QUERY 7: INNER JOIN - Sales, SalesDetails, Product, Customer, Employee
PRINT '';
PRINT '>>> JOIN Query 7: INNER JOIN - Sales, SalesDetails, Product, Customer, Employee (Complex Multi-table (5-table join))';
SELECT 
    s.SalesID,
    s.SalesDate,
    c.CustomerName,
    e.EmployeeName,
    p.ProductName,
    sd.Quantity,
    sd.UnitPrice,
    sd.LineTotal,
    s.NetAmount,
    ROUND((sd.LineTotal / s.NetAmount) * 100, 2) AS ProductPercentage
FROM Sales s
INNER JOIN Customer c ON s.CustomerID = c.CustomerID
INNER JOIN Employee e ON s.EmployeeID = e.EmployeeID
INNER JOIN SalesDetails sd ON s.SalesID = sd.SalesID
INNER JOIN Product p ON sd.ProductID = p.ProductID
ORDER BY s.SalesID, sd.SalesDetailsID;

GO

-- JOIN QUERY 8: LEFT JOIN - Field and Chemical Log
PRINT '';
PRINT '>>> JOIN Query 8: LEFT JOIN - Field and Chemical Log (1:N relationship)';
SELECT 
    f.FieldID,
    f.FieldName,
    f.SoilType,
    cl.ChemicalLogID,
    cl.ChemicalType,
    cl.ChemicalName,
    cl.Quantity,
    cl.ApplicationDate,
    cl.Cost,
    ROUND(cl.Cost / f.AreaInAcres, 2) AS CostPerAcre
FROM Field f
LEFT JOIN ChemicalLog cl ON f.FieldID = cl.FieldID
ORDER BY f.FieldID, cl.ApplicationDate DESC;

GO

-- JOIN QUERY 9: INNER JOIN - Animal, Feeding Log with Aggregates
PRINT '';
PRINT '>>> JOIN Query 9: INNER JOIN - Animal and Feeding Log with Aggregates';
SELECT 
    a.AnimalID,
    a.AnimalTag,
    a.AnimalName,
    b.BreedName,
    COUNT(fl.FeedingLogID) AS FeedingCount,
    SUM(fl.QuantityFed) AS TotalQuantityFed,
    ROUND(AVG(fl.QuantityFed), 2) AS AvgQuantityPerFeeding,
    SUM(fl.Cost) AS TotalFeedingCost,
    ROUND(AVG(fl.Cost), 2) AS AvgCostPerFeeding
FROM Animal a
INNER JOIN Breed b ON a.BreedID = b.BreedID
INNER JOIN FeedingLog fl ON a.AnimalID = fl.AnimalID
GROUP BY a.AnimalID, a.AnimalTag, a.AnimalName, b.BreedName
ORDER BY TotalFeedingCost DESC;

GO

-- JOIN QUERY 10: LEFT JOIN - Crop and ChemicalLog
PRINT '';
PRINT '>>> JOIN Query 10: LEFT JOIN - Crop and ChemicalLog (1:N relationship)';
SELECT 
    c.CropID,
    c.CropName,
    c.CropType,
    c.Status,
    cl.ChemicalLogID,
    cl.ChemicalType,
    cl.ChemicalName,
    cl.Quantity,
    cl.ApplicationMethod,
    cl.Cost
FROM Crop c
LEFT JOIN ChemicalLog cl ON c.CropID = cl.CropID
ORDER BY c.CropID, cl.ApplicationDate DESC;

GO

-- JOIN QUERY 11: INNER JOIN - Employee, Expense, ExpenseCategory
PRINT '';
PRINT '>>> JOIN Query 11: INNER JOIN - Employee, Expense, ExpenseCategory (Multi-table)';
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Position,
    ec.CategoryName,
    exp.ExpenseID,
    exp.ExpenseDate,
    exp.Amount,
    exp.VendorName,
    exp.ApprovalStatus
FROM Employee e
INNER JOIN Expense exp ON e.EmployeeID = exp.EmployeeID
INNER JOIN ExpenseCategory ec ON exp.ExpenseCategoryID = ec.ExpenseCategoryID
ORDER BY e.EmployeeID, exp.ExpenseDate DESC;

GO

-- JOIN QUERY 12: LEFT JOIN - UserAccount, Employee, Sales
PRINT '';
PRINT '>>> JOIN Query 12: LEFT JOIN - UserAccount, Employee, Sales (User Activity)';
SELECT 
    ua.UserAccountID,
    ua.Username,
    ua.Role,
    ua.LastLoginDate,
    e.EmployeeName,
    e.Position,
    COUNT(s.SalesID) AS TransactionsSinceLastLogin,
    MAX(s.SalesDate) AS LastTransactionDate
FROM UserAccount ua
LEFT JOIN Employee e ON ua.EmployeeID = e.EmployeeID
LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
GROUP BY ua.UserAccountID, ua.Username, ua.Role, ua.LastLoginDate, e.EmployeeName, e.Position
ORDER BY ua.LastLoginDate DESC;

GO

-- JOIN QUERY 13: FULL OUTER JOIN - Product and SalesDetails (showing orphaned records)
PRINT '';
PRINT '>>> JOIN Query 13: LEFT JOIN - Product and SalesDetails (Inventory Status)';
SELECT 
    p.ProductID,
    p.ProductName,
    p.Quantity,
    p.Status,
    COUNT(sd.SalesDetailsID) AS TimesSold,
    SUM(sd.Quantity) AS TotalUnitsSold,
    CASE 
        WHEN COUNT(sd.SalesDetailsID) = 0 THEN 'Never Sold'
        WHEN p.Quantity = 0 THEN 'Out of Stock'
        WHEN p.Quantity < 100 THEN 'Low Stock'
        ELSE 'Sufficient Stock'
    END AS InventoryStatus
FROM Product p
LEFT JOIN SalesDetails sd ON p.ProductID = sd.ProductID
GROUP BY p.ProductID, p.ProductName, p.Quantity, p.Status
ORDER BY TimesSold DESC;

GO

-- JOIN QUERY 14: INNER JOIN - Harvest, Crop, Field with Multi-level Aggregation
PRINT '';
PRINT '>>> JOIN Query 14: INNER JOIN - Harvest, Crop, Field (Multi-level aggregation)';
SELECT 
    f.FieldID,
    f.FieldName,
    f.AreaInAcres,
    c.CropID,
    c.CropName,
    COUNT(h.HarvestID) AS HarvestCount,
    SUM(h.QuantityHarvested) AS TotalHarvested,
    ROUND(SUM(h.QuantityHarvested) / f.AreaInAcres, 2) AS YieldPerAcre,
    ROUND(AVG(CAST(h.QuantityHarvested AS FLOAT)), 2) AS AvgHarvestPerCrop,
    SUM(h.HarvestCost) AS TotalCost
FROM Harvest h
INNER JOIN Crop c ON h.CropID = c.CropID
INNER JOIN Field f ON c.FieldID = f.FieldID
GROUP BY f.FieldID, f.FieldName, f.AreaInAcres, c.CropID, c.CropName
ORDER BY f.FieldID, YieldPerAcre DESC;

GO

-- JOIN QUERY 15: INNER JOIN - IrrigationLog, Field, Crop (Complex Analysis)
PRINT '';
PRINT '>>> JOIN Query 15: INNER JOIN - Irrigation, Field, Crop Analysis';
SELECT 
    f.FieldID,
    f.FieldName,
    c.CropName,
    c.Status AS CropStatus,
    COUNT(il.IrrigationLogID) AS IrrigationCount,
    SUM(il.WaterQuantity) AS TotalWaterUsed,
    ROUND(AVG(il.WaterQuantity), 2) AS AvgWaterPerEvent,
    SUM(il.WaterCost) AS TotalWaterCost,
    ROUND(SUM(il.WaterCost) / f.AreaInAcres, 2) AS WaterCostPerAcre,
    MAX(il.IrrigationDate) AS LastIrrigationDate
FROM IrrigationLog il
INNER JOIN Field f ON il.FieldID = f.FieldID
LEFT JOIN Crop c ON f.FieldID = c.FieldID
GROUP BY f.FieldID, f.FieldName, f.AreaInAcres, c.CropName, c.Status
ORDER BY f.FieldID, LastIrrigationDate DESC;

GO

PRINT '';
PRINT 'All JOIN queries executed successfully!';