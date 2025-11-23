
# 🔍 Entra ID (Azure AD) Sign-In Logs Export Script

This PowerShell script retrieves **the last 30 days of Microsoft Entra ID (Azure Active Directory)** sign-in logs using the **Microsoft Graph PowerShell SDK**.

It exports detailed authentication information including:

- 📅 Date / Time  
- 👤 UPN (User Principal Name)  
- 📱 Application Name  
- 🌍 IP Address  
- 🖥️ DeviceManaged (True/False)  
- 🏷️ TrustType (AzureAd, Workplace, ServerAd, Hybrid, etc.)  
- 🔗 CorrelationId  

Output is saved to:

**`SignInLogs_Last30Days.csv`**

---

## ✅ Features

- Fetches **30 days of logs** using safe **1-day batching** to avoid Graph throttling.
- Converts device trust type into readable text.
- Guarantees `DeviceManaged` is always **True/False**.
- Includes `CorrelationId` for troubleshooting authentication issues.
- Handles tenants with **large log volumes**.
- Uses the **latest Microsoft Graph endpoints**.

---

## 📦 Prerequisites

Install Microsoft Graph PowerShell SDK:

```powershell
Install-Module Microsoft.Graph -Force -AllowClobber
````

Run PowerShell as **Administrator** if this is your first installation.

---

## 🔐 Required Permissions

Your signed-in account must have the following Microsoft Graph delegated permissions:

* `AuditLog.Read.All`
* `Directory.Read.All`

Admin consent may be required depending on your organization.

---

## ▶️ How to Run the Script

1. Save the script file
2. Open **PowerShell**
3. Run:

```powershell
.\Fetch-SignInLogs.ps1
```

4. Sign in to Microsoft Graph when prompted
5. The CSV file will be created in your current directory

---

## 📁 CSV Output Columns

The exported CSV contains the following fields:

| Column        | Description                                |
| ------------- | ------------------------------------------ |
| Date          | Timestamp of the sign-in event             |
| UPN           | User principal name                        |
| AppName       | Application used during sign-in            |
| IPAddress     | Source IP address                          |
| DeviceManaged | Whether the device is Intune / AAD managed |
| TrustType     | Device trust classification                |
| CorrelationId | Useful for tracing incidents               |

---

## 📘 Official Microsoft Documentation

(Placeholders for you to replace with links)

* **Microsoft Graph API**
  👉 https://learn.microsoft.com/en-us/graph/use-the-api

* **Get-MgAuditLogSignIn*
  👉 *https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.reports/get-mgauditlogsignin?view=graph-powershell-1.0*

---

## 🛠️ Included PowerShell Script

The repository includes the full script that:

✔ Fetches 30 days of logs
✔ Maps TrustType to readable values
✔ Ensures DeviceManaged returns True/False
✔ Exports clean CSV output
✔ Displays sample results in console

---
