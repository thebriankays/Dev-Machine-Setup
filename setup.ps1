Function Invoke-RemoteScript {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[string]$address,
		[Parameter(ValueFromRemainingArguments = $true)]
		$remainingArgs
	)

	iex "& { $(irm $address) } $remainingArgs"
}

Function Install-OhMyPosh {
    [CmdletBinding()]
    param()

    . winget install JanDeDobbeleer.OhMyPosh -s winget
}

Function Install-TerminalIcons {
    [CmdletBinding()]
    param()

    Install-Module -Name Terminal-Icons -Repository PSGallery
}

Function Install-PSReadLine {
    [CmdletBinding()]
    param()

    Install-Module PSReadLine -AllowPrerelease -Force
}

Function Install-z {
    [CmdletBinding()]
    param()

    Install-Module z
}

Function Install-NerdFonts {

    BEGIN {
        $address = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip"
        $archive = "$($Env:TEMP)\CascadiaCode.zip"
        $folder = "$($Env:TEMP)\CascadiaCode"

        $shell = New-Object -ComObject Shell.Application
        $obj = $shell.Namespace(0x14)
        $systemFontsPath = $obj.Self.Path
    }

    PROCESS {

        Invoke-RestMethod `
            -Method Get `
            -Uri $address `
            -OutFile $archive

        Expand-Archive `
            -Path $archive `
            -DestinationPath $folder `
            -Force

        $shouldReboot = $false
        
        Get-ChildItem `
            -Path $folder |% {
                $path = $_.FullName
                $fontName = $_.Name
                
                $target = Join-Path -Path $systemFontsPath -ChildPath $fontName
                if (test-path $target) {
                    Write-Host "Ignoring $($path) as it already exists." -ForegroundColor DarkGray
                } else {
                    Write-Host "Installing $($path)..." -ForegroundColor Cyan
                    $obj.CopyHere($path)
                }
            }
    }

    END{
        Remove-Item `
            -Path $folder `
            -Recurse `
            -Force `
            -EA SilentlyContinue
    }

}

Set-Alias -Name irs -Value Invoke-RemoteScript

Install-NerdFonts
Install-OhMyPosh
Install-TerminalIcons
Install-PSReadline
Install-z