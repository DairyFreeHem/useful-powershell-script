

#
# Install a font on Windows
#


# Store the font file path in a variable
$fontFile = 'C:\FontFile.ttf'

# Create a font object from the font file
$font = New-Object System.Drawing.Text.PrivateFontCollection
$font.AddFontFile($fontFile)

# Get the first font from the collection
$installedFont = $font.Families[0]

# Install the font
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null
[System.Drawing.Text.InstalledFontCollection]::AddFontFile($fontFile)

