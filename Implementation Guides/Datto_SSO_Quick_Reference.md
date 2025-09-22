# Azure AD + Datto SSO - Quick Reference Checklist

## 📋 **Critical Configuration Values**

### Azure AD Configuration:
```
Identifier (Entity ID): https://portal.dattobackup.com/saml/metadata
Reply URL: https://portal.dattobackup.com/saml/consume  
Sign-on URL: https://portal.dattobackup.com/login
Logout URL: https://portal.dattobackup.com/logout
```

### Required Claims:
```
NameID: user.mail (Email format)
EmailAddress: user.mail
FirstName: user.givenname
LastName: user.surname
Groups: user.groups (optional)
```

---

## ✅ **Implementation Checklist**

### Phase 1: Azure AD Setup
- [ ] Create Enterprise Application "Datto Cloud Storage"
- [ ] Configure SAML single sign-on
- [ ] Set Basic SAML Configuration URLs
- [ ] Configure User Attributes & Claims
- [ ] Download Certificate (Base64)
- [ ] Copy Login URL and Azure AD Identifier
- [ ] Assign test users to application

### Phase 2: Datto Portal Setup  
- [ ] Login to portal.dattobackup.com
- [ ] Navigate to Settings → Single Sign-On
- [ ] Upload Azure AD certificate
- [ ] Configure SSO URL and Entity ID
- [ ] Map user attributes
- [ ] Enable auto-provisioning
- [ ] Set default user role

### Phase 3: Testing
- [ ] Test SSO connection from Datto
- [ ] Verify test user can login
- [ ] Check user attributes populated
- [ ] Confirm appropriate permissions
- [ ] Test logout functionality

---

## 🚨 **Common Issues & Quick Fixes**

| Issue | Quick Fix |
|-------|-----------|
| "Invalid SAML Response" | Check certificate format (Base64) and URLs match exactly |
| "User Not Found" | Enable auto-provisioning and verify EmailAddress claim |
| "Access Denied" | Check user assignment to Datto app in Azure AD |
| "Certificate Error" | Re-download and upload certificate, check expiration |

---

## 🔧 **PowerShell Quick Commands**

```powershell
# Connect to Azure AD
Connect-AzureAD

# Find Datto app
Get-AzureADServicePrincipal -Filter "DisplayName eq 'Datto Cloud Storage'"

# Check user assignments
Get-AzureADServiceAppRoleAssignment -ObjectId <ServicePrincipalObjectId>

# Test endpoints
Invoke-WebRequest -Uri "https://portal.dattobackup.com/saml/metadata"
```

---

## 📞 **Support Contacts**

- **Azure AD Issues**: Microsoft Support
- **Datto SSO Issues**: support.datto.com
- **SAML Troubleshooting**: Check both Azure AD and Datto logs

---

## 🎯 **Success Criteria**

✅ User can login to Datto using corporate credentials  
✅ User attributes sync correctly from Azure AD  
✅ Appropriate permissions assigned automatically  
✅ Logout works properly from both sides  
✅ No certificate warnings or errors