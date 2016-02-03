param([String] $version)

function AdjustPackages(
	[Parameter(ValueFromPipeline=$true)]
	[String]$pkg,
	
	[Parameter(Position = 0)]
	[String]$app
)
{
	Write-Verbose $app
	
	$inSection = $null;
	Foreach($line in $pkg)
	{	
		if($line -match "# BEGIN (?<section>[A-Za-z.]+)")
		{
			$inSection = $matches['section'];
			Write-Output $line;
			continue;
		} 
		elseif($inSection -and $line -match "# END $inSection")
		{
			$inSection = $null;
			Write-Output $line;
			continue;
		}
		
		if($inSection -eq $app) # in app section
		{
			Write-Output $line.TrimStart('#', ' ');
		}
		elseif(!$inSection) # in no section
		{
			Write-Output $line;
		}
		else # other section
		{
			Write-Output "# $line";
		}
	}
}

trap
{
    write-output $_
    ##teamcity[buildStatus status='FAILURE' ]
    exit 1
}

$app = $env:ApplicationName
$arch = "os.linux.x86_64"

if(!$app) {
	Throw "ApplicationName environment variable not set"
}

# remove old files

Remove-Item build\meteor\* -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item build\octopus\* -Force -Recurse -ErrorAction SilentlyContinue

# adapt packages
Get-Content .meteor\packages -Raw | AdjustPackages $app | Out-File .meteor\packages -Encoding utf8 -Append

# build

meteor build build/meteor --architecture $arch
if ($LASTEXITCODE -lt 0) {
    Throw "Meteor build failed; error code: $lastexitcode"
}

# package, including deploy.sh

Copy-Item deployment\deploy.sh build\meteor

build\octo.exe pack --id=$app --version=$version --basePath build\meteor --outFolder build\octopus --overwrite
if ($LASTEXITCODE -lt 0) {
    Throw "Packaging with Octo failed; error code: $lastexitcode"
}