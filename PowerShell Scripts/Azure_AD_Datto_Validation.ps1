# Azure AD + Datto SSO Validation Script
# Compatible with PowerShell 5.1 and later
# Run this script to validate your Azure AD configuration for Datto SSO

#Requires -Version 5.1
#Requires -Modules AzureAD

# ============================================================================
# CONFIGURATION SECTION - UPDATE THESE VALUES
# ============================================================================

$DattoAppName = "Datto Cloud Storage"
$TestUserPrincipalName = "testuser@yourdomain.com"  # Replace with your test user
$DattoMetadataUrl = "https://portal.dattobackup.com/saml/metadata"

# ============================================================================
# COMPATIBILITY CHECK
# ============================================================================

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Warning "This script requires PowerShell 5.1 or later. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

# Check if AzureAD module is available
if (-not (Get-Module -ListAvailable -Name AzureAD)) {
    Write-Warning "AzureAD module is not installed. Please run: Install-Module AzureAD -Force"
    exit 1
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

function Test-AzureADConnection {
    Write-Host "[INFO] Testing Azure AD Connection..." -ForegroundColor Cyan
    try {
        $context = Get-AzureADCurrentSessionInfo -ErrorAction Stop
        Write-Host "[SUCCESS] Connected to Azure AD Tenant: $($context.TenantDomain)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR] Not connected to Azure AD. Run 'Connect-AzureAD' first" -ForegroundColor Red
        return $false
    }
}

function Get-DattoEnterpriseApp {
    Write-Host "[INFO] Searching for Datto Enterprise Application..." -ForegroundColor Cyan
    try {
        $app = Get-AzureADApplication -Filter "DisplayName eq '$DattoAppName'" -ErrorAction Stop
        $servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$DattoAppName'" -ErrorAction Stop
        
        if ($app -and $servicePrincipal) {
            Write-Host "[SUCCESS] Found Datto Application: $($app.DisplayName)" -ForegroundColor Green
            Write-Host "   App ID: $($app.AppId)" -ForegroundColor Gray
            Write-Host "   Object ID: $($servicePrincipal.ObjectId)" -ForegroundColor Gray
            
            # PowerShell 5.1 compatible hashtable creation
            $result = @{}
            $result.Application = $app
            $result.ServicePrincipal = $servicePrincipal
            return $result
        }
        else {
            Write-Host "[ERROR] Datto application not found. Please create it first." -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "[ERROR] Failed to search for Datto application: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Test-DattoSAMLConfiguration {
    param($ServicePrincipal)
    
    Write-Host "[INFO] Checking SAML Configuration..." -ForegroundColor Cyan
    
    try {
        # Check if SAML SSO is configured
        $ssoSettings = Get-AzureADServicePrincipal -ObjectId $ServicePrincipal.ObjectId -ErrorAction Stop
        
        if ($ssoSettings.PreferredSingleSignOnMode -eq "saml") {
            Write-Host "[SUCCESS] SAML SSO Mode is configured" -ForegroundColor Green
        }
        else {
            Write-Host "[WARNING] SAML SSO Mode not set. Current mode: $($ssoSettings.PreferredSingleSignOnMode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] Failed to check SAML configuration: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Test-UserAssignments {
    param($ServicePrincipal, $TestUserPrincipalName)
    
    Write-Host "[INFO] Checking User Assignments..." -ForegroundColor Cyan
    
    try {
        # Get all assigned users
        $assignments = Get-AzureADServiceAppRoleAssignment -ObjectId $ServicePrincipal.ObjectId -ErrorAction Stop
        
        Write-Host "   Total assigned users/groups: $($assignments.Count)" -ForegroundColor Gray
        
        if ($TestUserPrincipalName -and $TestUserPrincipalName -ne "testuser@yourdomain.com") {
            try {
                $testUser = Get-AzureADUser -Filter "UserPrincipalName eq '$TestUserPrincipalName'" -ErrorAction Stop
                if ($testUser) {
                    $userAssignment = $assignments | Where-Object { $_.PrincipalId -eq $testUser.ObjectId }
                    if ($userAssignment) {
                        Write-Host "[SUCCESS] Test user $TestUserPrincipalName is assigned to Datto app" -ForegroundColor Green
                    }
                    else {
                        Write-Host "[ERROR] Test user $TestUserPrincipalName is NOT assigned to Datto app" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "[WARNING] Test user $TestUserPrincipalName not found in Azure AD" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "[ERROR] Failed to check test user: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "[INFO] No valid test user specified - update TestUserPrincipalName variable" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] Failed to get user assignments: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Test-DattoEndpoints {
    Write-Host "[INFO] Testing Datto Endpoints..." -ForegroundColor Cyan
    
    # Test metadata endpoint
    try {
        $response = Invoke-WebRequest -Uri $DattoMetadataUrl -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "[SUCCESS] Datto metadata endpoint accessible" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[WARNING] Datto metadata endpoint issue: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Test portal accessibility
    try {
        $portalResponse = Invoke-WebRequest -Uri "https://portal.dattobackup.com" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        if ($portalResponse.StatusCode -eq 200) {
            Write-Host "[SUCCESS] Datto portal accessible" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[WARNING] Datto portal accessibility issue: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Get-SAMLCertificateInfo {
    param($ServicePrincipal)
    
    Write-Host "[INFO] Checking SAML Certificate..." -ForegroundColor Cyan
    
    try {
        # Get certificate info (this is simplified - actual cert info requires more complex queries)
        $app = Get-AzureADApplication -Filter "AppId eq '$($ServicePrincipal.AppId)'" -ErrorAction Stop
        
        if ($app.KeyCredentials -and $app.KeyCredentials.Count -gt 0) {
            foreach ($cert in $app.KeyCredentials) {
                Write-Host "   Certificate Thumbprint: $($cert.KeyId)" -ForegroundColor Gray
                Write-Host "   Expires: $($cert.EndDate)" -ForegroundColor Gray
                
                # Check if certificate is expiring soon (within 30 days)
                if ($cert.EndDate) {
                    $daysUntilExpiry = ($cert.EndDate - (Get-Date)).Days
                    if ($daysUntilExpiry -lt 30) {
                        Write-Host "[WARNING] Certificate expires in $daysUntilExpiry days!" -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "[SUCCESS] Certificate is valid for $daysUntilExpiry days" -ForegroundColor Green
                    }
                }
            }
        }
        else {
            Write-Host "[WARNING] No certificates found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] Failed to check certificate info: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-ConfigurationSummary {
    param($DattoApp)
    
    Write-Host "`n[SUMMARY] Configuration Summary:" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "App Name: $($DattoApp.Application.DisplayName)"
    Write-Host "App ID: $($DattoApp.Application.AppId)"
    if ($DattoApp.Application.Homepage) {
        Write-Host "Homepage URL: $($DattoApp.Application.Homepage)"
    }
    Write-Host ""
    Write-Host "Required URLs for Datto Configuration:"
    Write-Host "Entity ID: https://portal.dattobackup.com/saml/metadata"
    Write-Host "Reply URL: https://portal.dattobackup.com/saml/consume"
    Write-Host "Sign-on URL: https://portal.dattobackup.com/login"
    Write-Host ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Host "Azure AD + Datto SSO Validation Script (PowerShell 5.1 Compatible)" -ForegroundColor Magenta
Write-Host "================================================================" -ForegroundColor Magenta
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host ""

# Import AzureAD module if not already loaded
try {
    Import-Module AzureAD -ErrorAction Stop
    Write-Host "[SUCCESS] AzureAD module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to import AzureAD module: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please install the module using: Install-Module AzureAD -Force" -ForegroundColor Yellow
    exit 1
}

# Test Azure AD connection
if (-not (Test-AzureADConnection)) {
    Write-Host "`n[ERROR] Please connect to Azure AD first using 'Connect-AzureAD'" -ForegroundColor Red
    exit 1
}

# Find Datto application
$dattoApp = Get-DattoEnterpriseApp
if (-not $dattoApp) {
    Write-Host "`n[ERROR] Cannot proceed without Datto application. Exiting." -ForegroundColor Red
    exit 1
}

# Run validation tests
Write-Host "`n=== Running Validation Tests ===" -ForegroundColor Cyan
Test-DattoSAMLConfiguration -ServicePrincipal $dattoApp.ServicePrincipal
Test-UserAssignments -ServicePrincipal $dattoApp.ServicePrincipal -TestUserPrincipalName $TestUserPrincipalName
Get-SAMLCertificateInfo -ServicePrincipal $dattoApp.ServicePrincipal
Test-DattoEndpoints

# Show summary
Show-ConfigurationSummary -DattoApp $dattoApp

Write-Host "`n[SUCCESS] Validation Complete!" -ForegroundColor Green
Write-Host "Review any warnings or errors above before proceeding with Datto configuration." -ForegroundColor Yellow

# Generate next steps
Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Download SAML certificate from Azure AD portal" -ForegroundColor White
Write-Host "2. Copy Login URL and Azure AD Identifier from Azure AD" -ForegroundColor White
Write-Host "3. Configure these in Datto Partner Portal" -ForegroundColor White
Write-Host "4. Test SSO connection from Datto portal" -ForegroundColor White
Write-Host "`nFor detailed instructions, see: Azure_AD_Datto_SSO_Complete_Guide.md" -ForegroundColor Gray
