--Import to Fact_Ledger
---- Truy v?n SaleLedger
SELECT 
    [SaleLedgerID] AS LedgerID,
    SA.[InventoryItemID],
    SA.[StockID],
    [InventoryLedgerID],
    SA.[ContractID],
    CASE WHEN IsVendor = 1 THEN a.accountobjectID END AS [VendorID],
    CASE WHEN IsCustomer = 1 THEN a.accountobjectID END AS [CustomerID],
    SA.[EmployeeID],
    SA.[RefNo],
    SA.[Refdate],
    SA.PostedDate,
    VATAmount,
    SA.[InvNo],
    SA.[JournalMemo],
    [DiscountRate],
    [VATRate],
    [ExportTaxRate],  -- C?t này có trong SaleLedger
    [ReturnQuantity],
    [ReduceAmount],
    SA.[Duedate],
    [ReceiptAmount],
    SaleAmount AS LedgerAmount,
    SaleQuantity AS LedgerQuantity,
    SA.UnitPrice,
    DiscountAmount,
    SA.InventoryItemCode,
    SA.AccountObjectID,
    SA.AccountObjectNameDI,
    SA.InventoryItemName,
    CASE WHEN SA.[InvNo] IS NULL THEN 0 ELSE 1 END AS InvoiceCreated,
    SA.RefTypeName,
    IsInvoiceExported,
    IsOutwardExported,
    STG_SAVoucher.RefNoFinance,
    STG_SAVoucher.RefNoManagement,
    SA.BranchID,
    0 AS LedgerType
FROM 
    STG_SaleLedger AS SA
left JOIN 
    dbo.STG_Accountobject a ON SA.accountobjectID = a.accountobjectID
left JOIN 
    STG_InventoryLedger ON STG_InventoryLedger.RefDetailID = SA.RefDetailID
left JOIN 
    STG_SAVoucher ON STG_SAVoucher.RefID = SA.RefID

UNION

-- Truy v?n PurchaseLedger
SELECT 
    [PurchaseLedgerID] AS LedgerID,
    PU.[InventoryItemID],
    PU.[StockID],
    [InventoryLedgerID],
    PU.[ContractID],
    CASE WHEN IsVendor = 1 THEN a.accountobjectID END AS [VendorID],
    CASE WHEN IsCustomer = 1 THEN a.accountobjectID END AS [CustomerID],
    PU.[EmployeeID],
    PU.[RefNo],
    PU.[Refdate],
    PU.PostedDate,
    VATAmount,
    PU.[InvNo],
    PU.[JournalMemo],
    [DiscountRate],
    [VATRate],
    NULL AS [ExportTaxRate],  -- C?t ExportTaxRate cho PurchaseLedger là NULL
    [ReturnQuantity],
    [ReduceAmount],
    PU.[Duedate],
    NULL AS [ReceiptAmount],  -- C?t ReceiptAmount cho PurchaseLedger là NULL
    PurchaseAmount AS LedgerAmount,
    PurchaseQuantity AS LedgerQuantity,
    PU.UnitPrice,
    DiscountAmount,
    PU.InventoryItemCode,
    PU.AccountObjectID,
    PU.AccountObjectNameDI,
    PU.InventoryItemName,
    CASE WHEN PU.[InvNo] IS NULL THEN 0 ELSE 1 END AS InvoiceCreated,
    PU.RefTypeName,
    NULL AS IsInvoiceExported,  -- C?t IsInvoiceExported cho PurchaseLedger là NULL
    NULL AS IsOutwardExported,  -- C?t IsOutwardExported cho PurchaseLedger là NULL
    [STG_PUVoucher].RefNoFinance,
    [STG_PUVoucher].RefNoManagement,
    PU.BranchID,
    1 AS LedgerType
FROM 
    STG_PurchaseLedger AS PU
 left JOIN 
    dbo.STG_Accountobject a ON PU.accountobjectID = a.accountobjectID
left JOIN 
    STG_InventoryLedger ON STG_InventoryLedger.RefDetailID = PU.RefDetailID
left JOIN 
    [STG_PUVoucher] ON [STG_PUVoucher].RefID = PU.RefID;
	
-- Datamart Debt_Receip_Cus
SELECT 
          VAO.[AccountObjectID]
      ,VAO.[AccountObjectCode]
      ,[AccountObjectName]
      ,[Gender]
      ,[BirthDate]
      ,[BirthPlace]
      ,[AgreementSalary]
      ,[SalaryCoefficient]
      ,[NumberOfDependent]
      ,[InsuranceSalary]
      ,[BankAccount]
      ,[BankName]
      ,[Address]
      ,[AccountObjectGroupList]
      ,[AccountObjectGroupListCode]
      ,[CompanyTaxCode]
      ,CASE WHEN AccountObjectType = 0 THEN [Tel] ELSE '' END AS [Tel]--N
      ,[Mobile]
      ,[Fax]
      ,[EmailAddress]
      ,[Website]
      ,[PaymentTermID]
      ,[MaximizeDebtAmount]
      ,[DueTime]
      ,[IdentificationNumber]
      ,[IssueDate]
      ,[IssueBy]
      ,[Country]
      ,[ProvinceOrCity]
      ,[District]
      ,[WardOrCommune]
      ,[ShippingAddress]
      ,[Prefix]
      ,[ContactName]
      ,[ContactTitle]
      ,[ContactMobile]
      ,[OtherContactMobile]
      ,[ContactFixedTel]
      ,[ContactEmail]
      ,[ContactAddress]
      ,[IsVendor]
      ,[IsCustomer]
      ,[IsEmployee]
      ,[AccountObjectType]
      ,[Inactive]
      ,[OrganizationUnitID]
      ,[BranchID]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[ModifiedDate]
      ,[ModifiedBy]      
      ,[DepartmentName]
      ,[GenderName]
          ,[InvReceiptableDebtAmount] = SUM(AL.InvDebtAmount)                                -- Số còn phải thu theo HĐ
          ,[AdvanceDeductionAmount] = SUM(AL.PrePayAmount)                                                                                        --Số thu trước / giảm trừ khác
          ,[ReceiptableDebtAmount]= SUM(AL.InvDebtAmount - AL.PrePayAmount)                --Số còn phải thu
        FROM [dbo].View_DIAccountObject VAO
                JOIN Kien_NoPaymentDebt AL ON VAO.AccountObjectID=AL.AccountObjectID                         
        GROUP BY
           VAO.[AccountObjectID]
      ,VAO.[AccountObjectCode]
      ,[AccountObjectName]
      ,[Gender]
      ,[BirthDate]
      ,[BirthPlace]
      ,[AgreementSalary]
      ,[SalaryCoefficient]
      ,[NumberOfDependent]
      ,[InsuranceSalary]
      ,[BankAccount]
      ,[BankName]
      ,[Address]
      ,[AccountObjectGroupList]
      ,[AccountObjectGroupListCode]
      ,[CompanyTaxCode]
      ,CASE WHEN AccountObjectType = 0 THEN [Tel] ELSE '' END
      ,[Mobile]
      ,[Fax]
      ,[EmailAddress]
      ,[Website]
      ,[PaymentTermID]
      ,[MaximizeDebtAmount]
      ,[DueTime]
      ,[IdentificationNumber]
      ,[IssueDate]
      ,[IssueBy]
      ,[Country]
      ,[ProvinceOrCity]
      ,[District]
      ,[WardOrCommune]
      ,[ShippingAddress]
      ,[Prefix]
      ,[ContactName]
      ,[ContactTitle]
      ,[ContactMobile]
      ,[OtherContactMobile]
      ,[ContactFixedTel]
      ,[ContactEmail]
      ,[ContactAddress]
      ,[IsVendor]
      ,[IsCustomer]
      ,[IsEmployee]
      ,[AccountObjectType]
      ,[Inactive]
      ,[OrganizationUnitID]
      ,[BranchID]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DepartmentName]
      ,[GenderName]  
      
                        
        ORDER BY [AccountObjectCode]
-- Dim_Customer
SELECT [AccountObject].[AccountObjectID] [CustomerID],
        [AccountObject].[AccountObjectName] [CustomerName],
        [Address],
        [CompanyTaxCode],
        sum([DebitAmount]) as [DebitAmount]
      ,sum([CreditAmount]) [CreditAmount],
        [AccountObjectLedger].[DueTime]
  FROM [AccountObject]
  left join [AccountObjectLedger] on [AccountObject].AccountObjectID = [AccountObjectLedger].AccountObjectID
  where IsCustomer = 1
  group by [AccountObject].[AccountObjectID], [AccountObject].[AccountObjectName], [Address], [CompanyTaxCode], [DueTime]
  
-- Datamart Debt_Customer
select 
Fact_Ledger.AccountObjectID, InvNo, Fact_Ledger.AccountObjectNameDI,
SUM(DebitAmount - CreditAmount) as  InvoiceAmount,
CASE WHEN Fact_Ledger.Duedate IS NULL THEN 10 WHEN Fact_Ledger.Duedate >= GETUTCDATE() THEN 1 ELSE 2 END AS DebtPeriodType,
ABS(DATEDIFF(DAY, GETUTCDATE(), Fact_Ledger.Duedate)) as RemainDebtDay from 
Fact_Ledger
 join Dim_Customer on Fact_Ledger.CustomerID = Dim_Customer.CustomerID
 GROUP BY Fact_Ledger.AccountObjectID, InvNo, Fact_Ledger.AccountObjectNameDI,
 CASE WHEN Fact_Ledger.Duedate IS NULL THEN 10 WHEN Fact_Ledger.Duedate >= GETUTCDATE() THEN 1 ELSE 2 END, 
 ABS(DATEDIFF(DAY, GETUTCDATE(), Fact_Ledger.Duedate))   HAVING SUM(DebitAmount - CreditAmount) > 0
 
 -- Datamart Item_acc_revenue: Doanh thu
 SELECT [AccountObjectID]
      ,[AccountObjectNameDI]
      ,[InventoryItemCode]
      ,[InventoryItemName]
      ,sum(LedgerAmount) [total_revenue]
      ,sum(LedgerQuantity) [total_sales]
      ,[RefDate]
          ,UnitPrice
          ,ReceiptAmount
          ,VATAmount
          ,RefNo
          ,InvNo
          ,PostedDate
          ,JournalMemo
          ,RefTypeName
          ,IsInvoiceExported
          ,IsOutwardExported
          ,RefNoFinance
          ,RefNoManagement
          ,DiscountAmount
          ,BranchID
  FROM Fact_Ledger
  where LedgerType = 0
  group by [AccountObjectID]
      ,[AccountObjectNameDI]
      ,[InventoryItemCode]
      ,[InventoryItemName]
          ,[RefDate]
          ,UnitPrice
          ,ReceiptAmount
          ,VATAmount
          ,RefNo
          ,InvNo
          ,PostedDate
          ,JournalMemo
          ,RefTypeName
          ,IsInvoiceExported
          ,IsOutwardExported
          ,RefNoFinance
          ,RefNoManagement
          ,InvoiceCreated
          ,DiscountAmount
          ,BranchID
