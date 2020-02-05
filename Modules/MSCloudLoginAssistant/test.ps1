
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Azure","AzureAD","SharePointOnline","ExchangeOnline", `
                     "SecurityComplianceCenter","MSOnline","PnP","PowerPlatforms", `
                     "MicrosoftTeams","SkypeForBusiness")]
        [System.String]
        $Platform,

        [Parameter()]
        [System.String]
        $ConnectionUrl,

        [Alias("o365Credential")]
        [System.Management.Automation.PSCredential]
        $CloudCredential,

        [Switch]
        $UseModernAuth,

        [System.String]
        $AppId,

        [System.String]
        $AppSecret,

        [System.String]
        $CertificateThumbprint,

        [System.String]
        $Tenant
    )

    # If we specified the CloudCredential parameter then set the global o365Credential object to its value
    if ($null -ne $CloudCredential)
    {
        $Global:o365Credential = $CloudCredential
        $Global:DomainName = $Global:o365Credential.UserName.Split('@')[1]
    }

    if ($null -eq $Global:UseApplicationIdentity)
    {
        $Global:UseApplicationIdentity = $AppId -ne $null
    }

    if($null -eq $Global:appIdentityParams) 
    {
        $Global:appIdentityParams = @{
            AppId = $AppId
            AppSecret = $AppSecret
            CertificateThumbprint = $CertificateThumbprint
            Tenant = $Tenant
            ServicePrincipalCredentials = $null
        }
    }

    if ($null -eq $Global:UseModernAuth)
    {
        $Global:UseModernAuth = $UseModernAuth.IsPresent
    }

    if($Global:UseApplicationIdentity)
    {
        if(-not $AppSecret -and -not $CertificateThumbprint) {
            Write-Information "Either a application secret or a certificate thumbprint must be provided"
            exit
        }

        $secpasswd = ConvertTo-SecureString $Global:appIdentityParams.AppSecret -AsPlainText -Force
        $spCreds = New-Object System.Management.Automation.PSCredential ($Global:appIdentityParams.AppId, $secpasswd)
        $Global:appIdentityParams.ServicePrincipalCredentials = $spCreds
    }
