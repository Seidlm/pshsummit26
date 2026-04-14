# Create a self-signed cert (good for demo, not production)
$cert = New-SelfSignedCertificate `
    -Subject "CN=PSHSummit-CodeSign" `
    -CertStoreLocation Cert:\CurrentUser\My `
    -KeyUsage DigitalSignature `
    -Type CodeSigningCert

# Sign a script
Set-AuthenticodeSignature -FilePath .\demo.ps1 -Certificate $cert

# Show the signature block
Get-Content .\NotAllowed.ps1 | Select-Object -Last 10

# Verify it
Get-AuthenticodeSignature .\NotAllowed.ps1 | Select-Object Status, SignerCertificate