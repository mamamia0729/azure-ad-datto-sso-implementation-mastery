# Datto SSO Implementation Checklist & Troubleshooting

## 📋 Pre-Implementation Checklist

### Prerequisites Verification:
- [ ] Datto Partner Portal Admin Access
- [ ] Identity Provider Admin Access  
- [ ] SSL Certificates Valid
- [ ] Network Connectivity Confirmed
- [ ] Test User Accounts Available

## 🚀 Step-by-Step Implementation

### Phase 1: Identity Provider Setup
- [ ] Create enterprise application/SAML app
- [ ] Configure basic SAML settings
- [ ] Set up user attributes and claims
- [ ] Download IdP certificate
- [ ] Note SSO URLs and Entity IDs
- [ ] Assign test users to application

### Phase 2: Datto Configuration  
- [ ] Access Datto Partner Portal SSO settings
- [ ] Upload IdP certificate
- [ ] Configure SSO URLs and Entity ID
- [ ] Map user attributes
- [ ] Enable auto-provisioning (if desired)
- [ ] Set default user roles

### Phase 3: Testing & Validation
- [ ] Test SSO connection from Datto portal
- [ ] Verify user can login via SSO
- [ ] Check user attributes populated correctly
- [ ] Confirm appropriate permissions assigned
- [ ] Test logout functionality
- [ ] Validate group-based access (if configured)

## 🔧 Common Configuration Issues

### 1. Certificate Problems:
```bash
# Check certificate format
openssl x509 -in certificate.crt -text -noout

# Common issue: Wrong certificate format
# Solution: Ensure Base64 encoded certificate
```

### 2. Attribute Mapping Issues:
```xml
<!-- Common mistake: Case sensitivity -->
Wrong: emailaddress
Correct: EmailAddress

<!-- Verify attribute names match exactly -->
```

### 3. URL Mismatches:
```
Common Issues:
- HTTP vs HTTPS
- Trailing slashes
- Wrong domain/subdomain

Verify:
✓ https://portal.dattobackup.com/saml/consume
✗ http://portal.dattobackup.com/saml/consume/
```

## 🚨 Troubleshooting Guide

### Issue: "Invalid SAML Response"
**Solutions:**
1. Verify certificate is correct and properly formatted
2. Check clock synchronization between IdP and Datto
3. Validate Entity ID matches exactly
4. Ensure SAML response is signed

### Issue: "User Not Found"
**Solutions:**  
1. Enable auto-provisioning in Datto
2. Verify email attribute mapping
3. Check user exists in IdP and is assigned to app
4. Validate NameID format (should be Email)

### Issue: "Access Denied"
**Solutions:**
1. Check user role assignments
2. Verify group mappings (if using groups)
3. Ensure user is assigned to Datto application in IdP
4. Check conditional access policies

### Issue: "Redirect Loop"
**Solutions:**
1. Verify SSO URLs are correct
2. Check for conflicting authentication methods
3. Clear browser cache and cookies
4. Validate RelayState configuration

## 📊 Testing Script

### PowerShell Test Commands:
```powershell
# Test SAML metadata accessibility
Invoke-WebRequest -Uri "https://portal.dattobackup.com/saml/metadata"

# Test IdP certificate
$cert = Get-Content "path/to/certificate.crt" -Raw
$cert64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cert))
```

### Validation URLs:
```
Datto Metadata: https://portal.dattobackup.com/saml/metadata
Test SSO: https://portal.dattobackup.com/login
```

## 📝 Documentation Requirements

### For Support/Audit:
- [ ] IdP configuration screenshots
- [ ] Datto SSO settings documentation  
- [ ] Certificate details and expiration dates
- [ ] User/group assignments
- [ ] Test results and validation logs
- [ ] Rollback procedures documented

## 🔄 Maintenance Tasks

### Regular Maintenance:
- Monitor certificate expiration (typically 1-3 years)
- Review user access quarterly
- Update group mappings as needed
- Test SSO functionality monthly
- Keep IdP and Datto configurations in sync

### Certificate Renewal Process:
1. Generate new certificate from IdP
2. Update certificate in Datto portal
3. Test SSO functionality
4. Update documentation
5. Schedule next renewal reminder