# Datto Partner Portal SSO Configuration

## Step 1: Access Datto Partner Portal
1. Login to **https://portal.dattobackup.com**
2. Navigate to **Settings** → **Single Sign-On**
3. Click **Enable SSO** or **Configure SAML**

## Step 2: SAML Configuration in Datto

### 2.1 Identity Provider Settings:
```
SSO URL (Login URL): [From Azure AD - Login URL]
Entity ID (Issuer): [From Azure AD - Azure AD Identifier] 
Certificate: [Upload the Base64 certificate from Azure AD]
```

### 2.2 Service Provider Settings (Auto-configured):
```
SP Entity ID: https://portal.dattobackup.com/saml/metadata
ACS URL: https://portal.dattobackup.com/saml/consume
```

### 2.3 Attribute Mapping:
```
Email: EmailAddress
First Name: FirstName  
Last Name: LastName
Groups: Groups (optional)
```

## Step 3: Advanced SSO Settings

### 3.1 User Provisioning Options:
- **Auto-provision users**: Create users automatically on first login
- **Just-in-time provisioning**: Update user attributes on each login
- **Group-based access**: Map AD groups to Datto roles

### 3.2 Default Role Assignment:
```
Options:
- Technician (basic access)
- Administrator (full access)  
- Custom roles based on group membership
```

## Step 4: Testing Configuration

### 4.1 Test SSO Connection:
1. Click **Test SSO** in Datto portal
2. Should redirect to your IdP login page
3. Verify successful authentication and user creation

### 4.2 Validation Checklist:
- [ ] User can login via SSO
- [ ] User attributes populated correctly
- [ ] Appropriate permissions assigned
- [ ] Logout works properly