# Datto Cloud Storage SSO with Azure AD Configuration

## Step 1: Azure AD Enterprise Application Setup

### 1.1 Create Enterprise Application
```bash
# Azure CLI method (optional)
az ad app create --display-name "Datto Cloud Storage" \
  --sign-in-audience AzureADMyOrg \
  --web-redirect-uris "https://portal.dattobackup.com/saml/consume"
```

### 1.2 Manual Azure Portal Steps:
1. Navigate to **Azure Active Directory** → **Enterprise Applications**
2. Click **+ New Application**
3. Select **Create your own application**
4. Name: "Datto Cloud Storage"
5. Select **Integrate any other application you don't find in the gallery**

## Step 2: SAML Configuration in Azure AD

### 2.1 Basic SAML Configuration:
- **Identifier (Entity ID)**: `https://portal.dattobackup.com/saml/metadata`
- **Reply URL**: `https://portal.dattobackup.com/saml/consume`
- **Sign on URL**: `https://portal.dattobackup.com/login`
- **Logout URL**: `https://portal.dattobackup.com/logout`

### 2.2 User Attributes & Claims:
```xml
Required Claims:
- NameID: user.mail (Email format)
- EmailAddress: user.mail
- FirstName: user.givenname  
- LastName: user.surname
- Groups: user.groups (if using group-based access)
```

### 2.3 Download Certificates:
- Download **Certificate (Base64)** from Azure AD
- Note down the **Login URL** and **Azure AD Identifier**

## Step 3: User/Group Assignment
1. Go to **Users and Groups** in the Enterprise App
2. Add users or groups that need Datto access
3. Assign appropriate roles if configured