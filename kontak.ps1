Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FILE
$file = "$env:USERPROFILE\Desktop\kontak_data.txt"
if (!(Test-Path $file)) { New-Item $file -ItemType File | Out-Null }

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = "Contact Manager"
$form.Size = '560,460'

# === PLACEHOLDER FUNCTION ===
function Set-Placeholder($tb, $text) {
    $tb.Text = $text
    $tb.ForeColor = [System.Drawing.Color]::Gray

    $tb.Add_GotFocus({
        if ($this.ForeColor -eq [System.Drawing.Color]::Gray) {
            $this.Text = ""
            $this.ForeColor = [System.Drawing.Color]::Black
        }
    })

    $tb.Add_LostFocus({
        if ($this.Text -eq "") {
            $this.Text = $text
            $this.ForeColor = [System.Drawing.Color]::Gray
        }
    })
}

# INPUTS
$txtID = New-Object System.Windows.Forms.TextBox
$txtID.Location = '20,20'
$txtID.Width = 80
Set-Placeholder $txtID "ID"

$txtNama = New-Object System.Windows.Forms.TextBox
$txtNama.Location = '110,20'
$txtNama.Width = 150
Set-Placeholder $txtNama "Nama Lengkap"

$txtHP = New-Object System.Windows.Forms.TextBox
$txtHP.Location = '270,20'
$txtHP.Width = 120
Set-Placeholder $txtHP "No HP"

$txtEmail = New-Object System.Windows.Forms.TextBox
$txtEmail.Location = '400,20'
$txtEmail.Width = 140
Set-Placeholder $txtEmail "Email"

$txtDesc = New-Object System.Windows.Forms.TextBox
$txtDesc.Location = '20,60'
$txtDesc.Size = '520,50'
$txtDesc.Multiline = $true
Set-Placeholder $txtDesc "Deskripsi / Catatan"

# LIST
$list = New-Object System.Windows.Forms.ListBox
$list.Location = '20,120'
$list.Size = '520,220'

# BUTTONS
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Add"
$btnAdd.Location = '20,360'

$btnEdit = New-Object System.Windows.Forms.Button
$btnEdit.Text = "Edit"
$btnEdit.Location = '120,360'

$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Text = "Delete"
$btnDelete.Location = '220,360'

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear"
$btnClear.Location = '320,360'

# FUNCTIONS
function Load-Data {
    $list.Items.Clear()
    $data = Get-Content $file -ErrorAction SilentlyContinue
    if ($data) { $list.Items.AddRange($data) }
}

function Get-Value($tb, $placeholder) {
    if ($tb.ForeColor -eq [System.Drawing.Color]::Gray) { "" } else { $tb.Text }
}

# ADD
$btnAdd.Add_Click({
    $id   = Get-Value $txtID "ID"
    $nama = Get-Value $txtNama "Nama Lengkap"
    $hp   = Get-Value $txtHP "No HP"
    $mail = Get-Value $txtEmail "Email"
    $desc = Get-Value $txtDesc "Deskripsi / Catatan"

    if ($id -and $nama -and $hp) {
        Add-Content $file "$id|$nama|$hp|$mail|$desc"
        Load-Data
    }
})

# EDIT
$btnEdit.Add_Click({
    if ($list.SelectedIndex -ge 0) {
        $data = Get-Content $file
        $data[$list.SelectedIndex] = "$(
            Get-Value $txtID 'ID'
        )|$(
            Get-Value $txtNama 'Nama Lengkap'
        )|$(
            Get-Value $txtHP 'No HP'
        )|$(
            Get-Value $txtEmail 'Email'
        )|$(
            Get-Value $txtDesc 'Deskripsi / Catatan'
        )"
        Set-Content $file $data
        Load-Data
    }
})

# DELETE (FIXED)
$btnDelete.Add_Click({
    if ($list.SelectedIndex -ge 0) {
        $data = Get-Content $file
        $new = @()
        for ($i=0; $i -lt $data.Count; $i++) {
            if ($i -ne $list.SelectedIndex) { $new += $data[$i] }
        }
        Set-Content $file $new
        Load-Data
    }
})

# CLEAR
$btnClear.Add_Click({
    Set-Placeholder $txtID "ID"
    Set-Placeholder $txtNama "Nama Lengkap"
    Set-Placeholder $txtHP "No HP"
    Set-Placeholder $txtEmail "Email"
    Set-Placeholder $txtDesc "Deskripsi / Catatan"
})

# SELECT
$list.Add_SelectedIndexChanged({
    if ($list.SelectedItem) {
        $p = $list.SelectedItem -split "\|"
        $txtID.Text = $p[0];     $txtID.ForeColor = 'Black'
        $txtNama.Text = $p[1];   $txtNama.ForeColor = 'Black'
        $txtHP.Text = $p[2];     $txtHP.ForeColor = 'Black'
        $txtEmail.Text = $p[3];  $txtEmail.ForeColor = 'Black'
        $txtDesc.Text = $p[4];   $txtDesc.ForeColor = 'Black'
    }
})

# LOAD
Load-Data

# ADD CONTROLS
$form.Controls.AddRange(@(
    $txtID,$txtNama,$txtHP,$txtEmail,$txtDesc,
    $list,
    $btnAdd,$btnEdit,$btnDelete,$btnClear
))

$form.ShowDialog()
