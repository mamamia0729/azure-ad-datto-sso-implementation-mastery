# Azure AD + Datto Cloud Storage SSO Implementation
## Complete Step-by-Step Guide

---

## 🔥 **Phase 1: Azure AD Enterprise Application Setup**

### Step 1.1: Create Enterprise Application
1. **Login to Azure Portal**: https://portal.azure.com
2. Navigate: **Azure Active Directory** → **Enterprise Applications**
3. Click **+ New application**
4. Select **Create your own application**
5. Enter name: **"Datto Cloud Storage"**
6. Select: **"Integrate any other application you don't find in the gallery"**
7. Click **Create**

### Step 1.2: Configure Single Sign-On
1. In your new **Datto Cloud Storage** app, click **Single sign-on**
2. Select **SAML** as the single sign-on method

---

## 🔧 **Phase 2: SAML Configuration in Azure AD**

### Step 2.1: Basic SAML Configuration
Click **Edit** on "Basic SAML Configuration" and enter:

```
Identifier (Entity ID): https://portal.dattobackup.com/saml/metadata
Reply URL (Assertion Consumer Service URL): https://portal.dattobackup.com/saml/consume
Sign on URL: https://portal.dattobackup.com/login
Logout URL: https://portal.dattobackup.com/logout
```

⚠️ **Important**: Make sure URLs are exactly as shown (case-sensitive, no trailing slashes)

### Step 2.2: User Attributes & Claims
Click **Edit** on "User Attributes & Claims":

#### Required Claims Configuration:
```
Name Identifier (NameID):
- Source: Attribute
- Source attribute: user.mail
- Name identifier format: Email Address

Additional Claims:
1. EmailAddress
   - Name: EmailAddress
   - Source: Attribute  
   - Source attribute: user.mail

2. FirstName
   - Name: FirstName
   - Source: Attribute
   - Source attribute: user.givenname

3. LastName  
   - Name: LastName
   - Source: Attribute
   - Source attribute: user.surname

4. Groups (Optional - for role-based access)
   - Name: Groups
   - Source: Attribute
   - Source attribute: user.groups
```

### Step 2.3: SAML Certificates
1. In **SAML Certificates** section, click **Download** next to **Certificate (Base64)**
2. Save this certificate file - you'll need it for Datto configuration
3. Copy the **Login URL** and **Azure AD Identifier** - you'll need these too

---

## 👥 **Phase 3: User Assignment in Azure AD**

### Step 3.1: Assign Users/Groups
1. Go to **Users and groups** in your Datto enterprise app
2. Click **+ Add user/group**
3. Select users or groups that need Datto access
4. Click **Assign**

### Step 3.2: Test User Setup
Create a test user first:
1. **Azure AD** → **Users** → **New user**
2. Create a test account with valid email
3. Assign to Datto application
4. Reset password and ensure user can login

---

## 🔐 **Phase 4: Datto Partner Portal Configuration**

### Step 4.1: Access Datto SSO Settings
1. Login to: **https://portal.dattobackup.com**
2. Navigate: **Settings** → **Account Settings** → **Single Sign-On**
3. Click **Configure SAML** or **Enable SSO**

### Step 4.2: Configure Identity Provider Settings
Enter the following from your Azure AD configuration:

```
SSO URL (Sign-on URL): [Login URL from Azure AD]
Entity ID (Issuer): [Azure AD Identifier from Azure AD]
X.509 Certificate: [Upload the Base64 certificate file downloaded from Azure AD]
```

### Step 4.3: Configure Service Provider Settings
These should auto-populate, but verify:
```
SP Entity ID: https://portal.dattobackup.com/saml/metadata
Assertion Consumer Service URL: https://portal.dattobackup.com/saml/consume
```

### Step 4.4: Attribute Mapping
Map the attributes to match Azure AD claims:
```
Email Address: EmailAddress
First Name: FirstName  
Last Name: LastName
Groups: Groups (if using group-based access)
```

### Step 4.5: User Provisioning Settings
Configure these options based on your needs:
- ✅ **Auto-provision users**: Creates users on first SSO login
- ✅ **Just-in-time provisioning**: Updates user info each login
- ⚠️ **Default role**: Choose appropriate default (Technician/Administrator)

---

## 🧪 **Phase 5: Testing & Validation**

### Step 5.1: Initial SSO Test
1. In Datto portal, click **Test SSO Connection**
2. Should redirect to Azure AD login page
3. Login with test user credentials
4. Should redirect back to Datto with successful login

### Step 5.2: End-to-End Testing Checklist
- [ ] User can access Datto via direct SSO link
- [ ] User attributes populated correctly in Datto
- [ ] User has appropriate permissions/role
- [ ] Logout functionality works
- [ ] User can access Datto resources they should have access to

### Step 5.3: Test Different Scenarios
- [ ] New user first-time login (auto-provisioning)
- [ ] Existing user login (attribute sync)
- [ ] User from different group (role assignment)
- [ ] Logout and re-login

---

## 🚨 **Phase 6: Troubleshooting Common Issues**

### Issue: "SAML Response Invalid"
**Check:**
1. Certificate uploaded correctly to Datto
2. URLs match exactly (case-sensitive)
3. Clock sync between Azure AD and Datto
4. Entity ID configured correctly

### Issue: "User Not Found"  
**Solutions:**
1. Enable auto-provisioning in Datto
2. Verify EmailAddress claim is configured
3. Check user is assigned to Datto app in Azure AD
4. Ensure NameID format is "Email Address"

### Issue: "Access Denied"
**Check:**
1. User assigned to Datto application in Azure AD
2. Default role configured in Datto
3. Group-based access rules (if using groups)
4. Conditional access policies not blocking

### Issue: "Certificate Error"
**Solutions:**
1. Re-download certificate from Azure AD
2. Ensure Base64 format (not Binary)
3. Check certificate hasn't expired
4. Verify certificate uploaded to correct field in Datto

---

## 📊 **Phase 7: Production Rollout**

### Step 7.1: Staged Rollout Plan
1. **Phase 1**: IT/Admin team (5-10 users)
2. **Phase 2**: Department leads (20-30 users)  
3. **Phase 3**: All users requiring Datto access

### Step 7.2: User Communication
Create communication including:
- New login URL: https://portal.dattobackup.com/login
- Instructions to use corporate credentials
- Who to contact for support
- Timeline for rollout

### Step 7.3: Monitor and Support
- Monitor Azure AD sign-in logs for SSO failures
- Check Datto logs for authentication issues
- Have rollback plan ready (keep local accounts as backup)

---

## 🔄 **Phase 8: Ongoing Maintenance**

### Monthly Tasks:
- [ ] Review failed sign-in attempts in Azure AD
- [ ] Check certificate expiration dates
- [ ] Validate user access is appropriate
- [ ] Test SSO functionality

### Quarterly Tasks:  
- [ ] Review user/group assignments
- [ ] Update role mappings if needed
- [ ] Document any configuration changes
- [ ] Test disaster recovery procedures

### Annual Tasks:
- [ ] Certificate renewal (typically 1-3 years)
- [ ] Security review of SSO configuration
- [ ] User access audit
- [ ] Update documentation

---

## 📋 **Quick Reference Commands**

### PowerShell Commands for Testing:
```powershell
# Test Datto metadata endpoint
Invoke-WebRequest -Uri "https://portal.dattobackup.com/saml/metadata"

# Check certificate details
$cert = Get-Content "path/to/downloaded-cert.cer" -Raw
$certObj = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([System.Convert]::FromBase64String($cert))
$certObj | Select-Object Subject, NotAfter, Thumbprint
```

### Azure CLI Commands:
```bash
# List enterprise applications
az ad app list --display-name "Datto Cloud Storage"

# Check user assignments
az ad app show --id <app-id> --query "requiredResourceAccess"
```

---

## 📞 **Support Contacts**

- **Azure AD Issues**: Microsoft Support or your Azure administrator
- **Datto SSO Issues**: Datto Support (support.datto.com)
- **Integration Issues**: Check both Azure AD and Datto logs

---

## ✅ **Final Validation Checklist**

Before going live, ensure:
- [ ] Test user can login successfully via SSO
- [ ] User attributes sync correctly
- [ ] Appropriate roles/permissions assigned  
- [ ] Logout works properly
- [ ] Certificate is valid and not expiring soon
- [ ] Backup authentication method available
- [ ] Documentation is complete and accessible
- [ ] Support team is trained on troubleshooting