# Datto SSO with Alternative Identity Providers

## Okta Configuration

### 1. Create Okta Application:
1. **Admin Console** → **Applications** → **Create App Integration**
2. Select **SAML 2.0**
3. App Name: "Datto Cloud Storage"

### 2. SAML Settings:
```
Single Sign-On URL: https://portal.dattobackup.com/saml/consume
Audience URI: https://portal.dattobackup.com/saml/metadata
Default RelayState: (leave blank)
Name ID format: EmailAddress
Application username: Email
```

### 3. Attribute Statements:
```
Name: EmailAddress, Value: user.email
Name: FirstName, Value: user.firstName  
Name: LastName, Value: user.lastName
```

---

## Google Workspace Configuration

### 1. Admin Console Setup:
1. **Apps** → **Web and mobile apps** → **Add custom SAML app**
2. App name: "Datto Cloud Storage"

### 2. Google IdP Details (for Datto):
```
SSO URL: https://accounts.google.com/o/saml2/idp?idpid=[YOUR_IDP_ID]
Entity ID: https://accounts.google.com/o/saml2?idpid=[YOUR_IDP_ID]
Certificate: [Download from Google]
```

### 3. Service Provider Details:
```
ACS URL: https://portal.dattobackup.com/saml/consume
Entity ID: https://portal.dattobackup.com/saml/metadata
Start URL: https://portal.dattobackup.com/login
```

### 4. Attribute Mapping:
```
Email: Primary Email
First Name: First Name
Last Name: Last Name  
```

---

## ADFS Configuration

### 1. Add Relying Party Trust:
```powershell
# PowerShell commands for ADFS
Add-AdfsRelyingPartyTrust -Name "Datto Cloud Storage" `
  -Identifier "https://portal.dattobackup.com/saml/metadata" `
  -AccessControlPolicyName "Permit everyone"
```

### 2. Claim Rules:
```
Transform Claim Rules:
1. LDAP Attributes → SAML Attributes
   - E-Mail-Addresses → E-Mail Address
   - Given-Name → First Name  
   - Surname → Last Name

2. Transform Incoming Claim
   - Incoming claim type: E-Mail Address
   - Outgoing claim type: Name ID
   - Outgoing name ID format: Email
```

### 3. Endpoints:
```
SAML 2.0 SSO: https://your-adfs-server/adfs/ls/
SAML 2.0 Logout: https://your-adfs-server/adfs/ls/?wa=wsignout1.0
```