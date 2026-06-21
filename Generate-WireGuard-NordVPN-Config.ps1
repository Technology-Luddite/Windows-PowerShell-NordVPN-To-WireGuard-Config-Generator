Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- PATH CONFIGURATION ---
$targetDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($targetDir)) { $targetDir = Get-Location }
$tokenFilePath = Join-Path -Path $targetDir -ChildPath "NordVPN-Access-Token.config"

# --- UI WINDOW SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "NordVPN to WireGuard Config Generator - Ver: 1.0"
$form.Size = New-Object System.Drawing.Size(460, 220)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# --- FONT ---
$defaultFont = New-Object System.Drawing.Font("Segoe UI", 10)
$labelFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# --- 1. LABEL ---
$label = New-Object System.Windows.Forms.Label
$label.Text = "Paste Your NordVPN Access Token Here:"
$label.Location = New-Object System.Drawing.Point(25, 20)
$label.Size = New-Object System.Drawing.Size(400, 25)
$label.Font = $labelFont
$form.Controls.Add($label)

# --- 2. TEXTBOX ---
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(25, 50)
$textBox.Size = New-Object System.Drawing.Size(400, 25)
$textBox.Font = $defaultFont

# Check for existing token file and prepopulate
if (Test-Path -Path $tokenFilePath) {
    $savedToken = (Get-Content -Path $tokenFilePath -Raw).Trim()
    $textBox.Text = $savedToken
}
$form.Controls.Add($textBox)

# --- 3. BUTTON ---
$button = New-Object System.Windows.Forms.Button
$button.Text = "Generate WireGuard Config"
$button.Location = New-Object System.Drawing.Point(25, 95)
$button.Size = New-Object System.Drawing.Size(400, 40)
$button.Font = $labelFont
$button.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$button.ForeColor = [System.Drawing.Color]::White
$button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($button)

# --- BACKEND LOGIC (Button Click Event) ---
$button.Add_Click({
    $accessToken = $textBox.Text.Trim()

    if ([string]::IsNullOrEmpty($accessToken)) {
        [System.Windows.Forms.MessageBox]::Show("Please paste a valid access token first!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $button.Enabled = $false
    $button.Text = "Fetching Keys from Nord API..."
    $form.Refresh()

    try {
        # 1. Authenticate & Fetch Private Key
        $credentials = "token:$accessToken"
        $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($credentials))
        $headers = @{ "Authorization" = "Basic $encodedCredentials" }

        $profileResponse = Invoke-RestMethod -Uri "https://api.nordvpn.com/v1/users/services/credentials" -Headers $headers -Method Get
        $privateKey = $profileResponse.nordlynx_private_key

        if ([string]::IsNullOrEmpty($privateKey)) {
            throw "Could not retrieve Private Key. Your access token might be invalid or expired."
        }

        # Save token file ONLY if it doesn't already exist (Read-Only behavior)
        if (-not (Test-Path -Path $tokenFilePath)) {
            $accessToken | Out-File -FilePath $tokenFilePath -Encoding utf8 -Force
        }

        # 2. Query recommended WireGuard server
        $serverRequest = Invoke-RestMethod -Uri "https://api.nordvpn.com/v1/servers/recommendations?&filters[servers_technologies][identifier]=wireguard_udp&limit=1"
        
        $serverName = $serverRequest.name
        $endpointIP = $serverRequest.station
        
        $wireguardTech = $serverRequest.technologies | Where-Object { $_.identifier -eq 'wireguard_udp' }
        $publicKey = $wireguardTech.metadata | Where-Object { $_.name -eq 'public_key' } | Select-Object -ExpandProperty value

        # 3. Compile the .conf template using standard string array joining
        $confLines = @(
            "[Interface]",
            "PrivateKey = $privateKey",
            "Address = 10.5.0.2/32",
            "DNS = 103.86.96.100, 103.86.99.100",
            "",
            "[Peer]",
            "PublicKey = $publicKey",
            "Endpoint = $($endpointIP):51820",
            "AllowedIPs = 0.0.0.0/0"
        )
        $confContent = $confLines -join "`r`n"

        # --- DYNAMIC FILENAME GENERATION ---
        $cleanServerName = $serverName -replace '[\s#]', ''
        $fileName = "NordVPN-$cleanServerName-config.conf"

        # 4. Save file to the script's execution folder
        $outputPath = Join-Path -Path $targetDir -ChildPath $fileName
        $confContent | Out-File -FilePath $outputPath -Encoding utf8 -Force

        # Success message!
        [System.Windows.Forms.MessageBox]::Show("Success!`n`nConfig saved as: $fileName`nLocation: $outputPath", "Configuration Generated", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        
    } catch {
        # Catch Bad Request (400) errors cleanly and map them to your warning message
        if ($_.Exception.Message -match "400") {
            [System.Windows.Forms.MessageBox]::Show("Warning: Please verify Access Token is correct and try again!", "Invalid Token", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            # Let other system errors through natively
            [System.Windows.Forms.MessageBox]::Show("An error occurred:`n`n$($_.Exception.Message)", "API Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } finally {
        # Reset button state
        $button.Enabled = $true
        $button.Text = "Generate WireGuard Config"
    }
})

# --- DISPLAY THE WINDOW ---
$form.ShowDialog() | Out-Null