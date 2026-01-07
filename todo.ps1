Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FILE
$file = "$env:USERPROFILE\Desktop\todo_data.txt"
if (!(Test-Path $file)) { New-Item $file -ItemType File | Out-Null }

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = "Todo List"
$form.Size = '500,420'
$form.BackColor = '#F4F6F8'
$form.StartPosition = 'CenterScreen'

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "📝 My Todo List"
$title.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$title.Location = '20,15'
$title.AutoSize = $true

# PLACEHOLDER FUNCTION
function Set-Placeholder($tb,$text){
    $tb.Text = $text
    $tb.ForeColor = 'Gray'
    $tb.Add_GotFocus({
        if ($this.ForeColor -eq 'Gray') {
            $this.Text=""
            $this.ForeColor='Black'
        }
    })
    $tb.Add_LostFocus({
        if ($this.Text -eq "") {
            $this.Text=$text
            $this.ForeColor='Gray'
        }
    })
}

# INPUT
$txtTodo = New-Object System.Windows.Forms.TextBox
$txtTodo.Location = '20,55'
$txtTodo.Width = 340
$txtTodo.Font = 'Segoe UI,10'
Set-Placeholder $txtTodo "Tambah todo baru..."

# ADD BUTTON
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Add"
$btnAdd.Location = '370,52'
$btnAdd.Width = 90
$btnAdd.BackColor = '#4CAF50'
$btnAdd.ForeColor = 'White'
$btnAdd.FlatStyle = 'Flat'

# LIST
$list = New-Object System.Windows.Forms.CheckedListBox
$list.Location = '20,95'
$list.Size = '440,220'
$list.Font = 'Segoe UI,10'
$list.CheckOnClick = $true

# BUTTONS
$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Text = "Delete"
$btnDelete.Location = '20,330'
$btnDelete.Width = 90

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear All"
$btnClear.Location = '120,330'
$btnClear.Width = 90

# LOAD
function Load-Data {
    $list.Items.Clear()
    $data = Get-Content $file -ErrorAction SilentlyContinue
    foreach ($d in $data) {
        $p = $d -split "\|"
        $idx = $list.Items.Add($p[1])
        if ($p[0] -eq "1") { $list.SetItemChecked($idx,$true) }
    }
}

# SAVE
function Save-Data {
    $out = @()
    for ($i=0; $i -lt $list.Items.Count; $i++) {
        $status = if ($list.GetItemChecked($i)) {1} else {0}
        $out += "$status|$($list.Items[$i])"
    }
    Set-Content $file $out
}

# EVENTS
$btnAdd.Add_Click({
    if ($txtTodo.ForeColor -ne 'Gray' -and $txtTodo.Text) {
        $list.Items.Add($txtTodo.Text)
        Set-Placeholder $txtTodo "Tambah todo baru..."
        Save-Data
    }
})

$list.Add_ItemCheck({ Start-Sleep -Milliseconds 50; Save-Data })

$btnDelete.Add_Click({
    if ($list.SelectedIndex -ge 0) {
        $list.Items.RemoveAt($list.SelectedIndex)
        Save-Data
    }
})

$btnClear.Add_Click({
    $list.Items.Clear()
    Clear-Content $file
})

# INIT
Load-Data

# ADD CONTROLS
$form.Controls.AddRange(@(
    $title,$txtTodo,$btnAdd,
    $list,$btnDelete,$btnClear
))

$form.ShowDialog()
