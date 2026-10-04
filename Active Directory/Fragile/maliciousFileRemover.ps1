
# Windows form app to delete files from a certain path

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Drawing
    
# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}


#Create windows form
function show-dialogBox
{
    while ($true) {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Please insert file path'
        $form.Size = New-Object System.Drawing.Size(250,200)
        $form.StartPosition = 'CenterScreen'
    
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10,20)
        $label.Size = New-Object System.Drawing.Size(280,20)
        $label.Text = 'Enter location to delete:'
        $form.Controls.Add($label)
        
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(10,40)
        $textBox.Size = New-Object System.Drawing.Size(200,20)

        $form.Controls.Add($textBox)

        $selectFileButton = New-Object System.Windows.Forms.Button
        $selectFileButton.Location = New-Object System.Drawing.Point(10,70)
        $selectFileButton.Size = New-Object System.Drawing.Size(75,23)
        $selectFileButton.Text = 'File'
        $selectFileButton.add_click(
            {
                $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
                $folderDialog.Description = "Select a folder"
                $folderDialog.RootFolder = "Desktop"
                $result = $folderDialog.ShowDialog()
                if ($result -eq "OK")
                {
                    $selectedFolder = $folderDialog.SelectedPath
                    $textBox.Text = $selectedFolder
                }
            }
        )
        $form.Controls.Add($selectFileButton)
        
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Point(80,120)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)
        $form.Topmost = $true
        
        $form.Add_Shown({$textBox.Select()})

        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            if ($textBox.Text -ne '') {
                $fullPath = $textBox.Text + '\*'
                return $fullPath
            }
            else {
                [System.Windows.MessageBox]::Show('No file path was inserted','No text found','OK','Error')
            }
        }
        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            exit
        }
    }
}

#Get Path to delete
$path = show-dialogBox
$extensions = "*.exe","*.vbx","*.ps1","*.bat","*.com","*.dll"

#Get files from path
$toDelete = Get-ChildItem -Path $path -Include $extensions -Recurse -Force | Where-Object {(!$_.PSIsContainer)}
Write-Output $toDelete

#delete files
$toDelete | Remove-Item -WhatIf
