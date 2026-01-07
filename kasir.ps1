Add-Type -AssemblyName System.Windows.Forms

$file = "$env:USERPROFILE\Desktop\kasir_data.txt"
if (!(Test-Path $file)) { New-Item $file -ItemType File | Out-Null }

# === FORM ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "KASIR MINI"
$form.Size = '600,450'

# === INPUT ===
$txtItem = New-Object System.Windows.Forms.TextBox
$txtItem.Location = '20,20'
$txtItem.Width = 150
$txtItem.PlaceholderText = "Item"

$txtQty = New-Object System.Windows.Forms.TextBox
$txtQty.Location = '180,20'
$txtQty.Width = 60
$txtQty.PlaceholderText = "Qty"

$txtHarga = New-Object System.Windows.Forms.TextBox
$txtHarga.Location = '250,20'
$txtHarga.Width = 100
$txtHarga.PlaceholderText = "Harga"

# === LIST ===
$list = New-Object System.Windows.Forms.ListView
$list.Location = '20,60'
$list.Size = '540,250'
$list.View = 'Details'
$list.FullRowSelect = $true
$list.Columns.Add("Item",150)
$list.Columns.Add("Qty",50)
$list.Columns.Add("Harga",120)
$list.Columns.Add("Total",120)

# === TOTAL LABEL ===
$lblTotal = New-Object System.Windows.Forms.Label
$lblTotal.Location = '20,320'
$lblTotal.Size = '300,30'
$lblTotal.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
$lblTotal.Text = "TOTAL: Rp 0"

# === BUTTON ===
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Tambah"
$btnAdd.Location = '380,20'

$btnEdit = New-Object System.Windows.Forms.Button
$btnEdit.Text = "Edit"
$btnEdit.Location = '460,20'

$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Text = "Hapus"
$btnDelete.Location = '540,20'

# === FUNCTIONS ===
function Load-Data {
    $list.Items.Clear()
    $totalAll = 0
    $data = Get-Content $file -ErrorAction SilentlyContinue
    if ($data) {
        foreach ($line in $data) {
            $p = $line -split "\|"
            $item = New-Object System.Windows.Forms.ListViewItem($p[0])
            $item.SubItems.Add($p[1])
            $item.SubItems.Add("Rp $($p[2])")
            $item.SubItems.Add("Rp $($p[3])")
            $list.Items.Add($item)
            $totalAll += [int]$p[3]
        }
    }
    $lblTotal.Text = "TOTAL: Rp $totalAll"
}

function Clear-Input {
    $txtItem.Clear()
    $txtQty.Clear()
    $txtHarga.Clear()
}

# === LOGIC ===
$btnAdd.Add_Click({
    if ($txtItem.Text -and $txtQty.Text -and $txtHarga.Text) {
        $total = [int]$txtQty.Text * [int]$txtHarga.Text
        "$($txtItem.Text)|$($txtQty.Text)|$($txtHarga.Text)|$total" | Add-Content $file
        Clear-Input
        Load-Data
    }
})

$btnEdit.Add_Click({
    if ($list.SelectedItems.Count -gt 0) {
        $index = $list.SelectedItems[0].Index
        $data = Get-Content $file
        $total = [int]$txtQty.Text * [int]$txtHarga.Text
        $data[$index] = "$($txtItem.Text)|$($txtQty.Text)|$($txtHarga.Text)|$total"
        Set-Content $file $data
        Clear-Input
        Load-Data
    }
})

$btnDelete.Add_Click({
    if ($list.SelectedItems.Count -gt 0) {
        $index = $list.SelectedItems[0].Index
        $data = Get-Content $file
        $data = $data | Where-Object { $_ -ne $data[$index] }
        Set-Content $file $data
        Clear-Input
        Load-Data
    }
})

$list.Add_SelectedIndexChanged({
    if ($list.SelectedItems.Count -gt 0) {
        $row = $list.SelectedItems[0]
        $txtItem.Text = $row.SubItems[0].Text
        $txtQty.Text = $row.SubItems[1].Text
        $txtHarga.Text = ($row.SubItems[2].Text -replace "Rp ","")
    }
})

# === ADD CONTROL ===
$form.Controls.AddRange(@(
    $txtItem,$txtQty,$txtHarga,
    $btnAdd,$btnEdit,$btnDelete,
    $list,$lblTotal
))

Load-Data
$form.ShowDialog()
