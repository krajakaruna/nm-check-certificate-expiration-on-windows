#==========================================================
# MODIFIED BY: KRajakaruna
# DATE: 2021-12-13
# VERSION: 1.1
# CHANGES: Check if the cerficate is dissabled 
#		   before chekcing the expire date
#==========================================================
#==========================================================

Param(
 [int]$critical = 10,
 [switch]$help,
 [int]$warning = 20
)

$scriptversion = "1.0"

$CERTDIR = "Cert:\CurrentUser\My"

$bReturnOK = $TRUE
$bReturnCritical = $FALSE
$bReturnWarning = $FALSE
$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3
$nWarning = $warning
$nCritical = $critical

$dtCurrent = Get-Date

$strCritical = ""
$strWarning = ""

# $certificateDissabled = $FALSE

if ($help)
{
 Write-Output ""
 Write-Output "---------------------------------------------"
 Write-Output "check-certificate-expiration.ps1 v.$scriptversion"
 Write-Output "---------------------------------------------"
 Write-Output ""
 Write-Output "Options:"
 Write-Output "-c or -critical (number)"
 Write-Output "-h or -help display help"
 Write-Output "-w or -warning (number)"
 Write-Output "" 
 Write-Output "Example:"
 Write-Output ".\check-certificate-expiration.ps1 -c 4 -w 10"
 Write-Output ""
 Write-Output "For more information visit:"
 Write-Output "http://networklore.com/nelmon/"
 Write-Output "http://networklore.com/windows-certificate-expiration/"
 Write-Output ""
 exit $returnStateUnknown
} 


$objCertificates = Get-Childitem $CERTDIR

if (-Not $objCertificates)
{ 
 Write-Output "No Certificates Found"
 exit $bReturnOK
}

foreach ($objCertificate in $objCertificates)
{
 $dtRemain =  $objCertificate.NotAfter - $dtCurrent
 $nRemainDays = $dtRemain.Days
 
#Check if the certificate is dissabled.
if(-Not $objCertificate.EnhancedKeyUsageList)
{
	# $certificateDissabled = $TRUE
	Write-Output "$($objCertificate.Subject) $("certificate_dissabled")"
} else
{

   if ($nRemainDays -lt 0)
 	{
	$strCritical = $strCritical + "EXPIRED " + $objCertificate.SubjectName.Name.ToString() + " expired " + $objCertificate.NotAfter.ToString() + "`n"
	$bReturnCritical = $TRUE
 	} Elseif ( $nRemainDays -lt $nCritical)
 	{
    $strCritical = $strCritical +  "Critical " + $objCertificate.SubjectName.Name.ToString() + " expires " + $objCertificate.NotAfter.ToString() + "`n"
	$bReturnCritical = $TRUE
 	} Elseif ( $nRemainDays -lt $nWarning)
 	{
    $strWarning = $strWarning + "Warning " + $objCertificate.SubjectName.Name.ToString() + " expires " + $objCertificate.NotAfter.ToString() + "`n"
	$bReturnWarning = $TRUE
 	} Else
 	{
	#Nothing for now
 	}

}

}

if ($bReturnCritical)
{
 write-output $strCritical
 write-output $strWarning
 exit $returnStateCritical
} elseif ($bReturnWarning)
{
 write-output $strWarning
 exit $returnStateWarning
} else
{
 write-output "OK"
 exit $returnStateOK
}
