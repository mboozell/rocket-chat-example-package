param([String]$app)

$pkg = Get-Content .meteor\packages;

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