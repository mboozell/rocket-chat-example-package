param([String] $id)

trap
{
    write-output $_
    ##teamcity[buildStatus status='FAILURE' ]
    exit 1
}

$version = "%build.number%"
$arch = "os.linux.x86_64"

# remove old files

Remove-Item build\meteor\* -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item build\octopus\* -Force -Recurse -ErrorAction SilentlyContinue

# adapt packages

./SetPackages.ps1 $id > build\meteor

# build

meteor build build\meteor --architecture $arch
if ($LASTEXITCODE -lt 0)
{
    Throw "Meteor build failed; error code: $lastexitcode"
}

# package, including deploy.sh

Copy-Item deployment\deploy.sh build\meteor

build\octo.exe pack --id=$id --version=$version --basePath build\meteor --outFolder build\octopus --overwrite
if ($LASTEXITCODE -lt 0)
{
    Throw "Packaging with Octo failed; error code: $lastexitcode"
}